from django.http import JsonResponse
from .models import Usuario, Rol, ClasificacionDenuncia, Denuncia, ImagenDenuncia
from django.contrib.auth.hashers import make_password, check_password
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.views import View
from datetime import datetime, timedelta
import json
import jwt
from django.conf import settings
from django.db import transaction, IntegrityError
from datetime import datetime

class AdminRequiredView(View):
    """
    Base view que exime CSRF y requiere un JWT válido
    de un usuario con rol 'Administrador' para todos los métodos HTTP.
    """
    @method_decorator(csrf_exempt)
    def dispatch(self, request, *args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return JsonResponse({'error': 'Token no proporcionado.'}, status=401)
        token = auth_header.split()[1]
        try:
            payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        except jwt.ExpiredSignatureError:
            return JsonResponse({'error': 'Token expirado.'}, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({'error': 'Token inválido.'}, status=401)

        try:
            user = Usuario.objects.get(id=payload['user_id'])
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)

        if not user.rol or user.rol.nombre != 'Administrador':
            return JsonResponse({'error': 'Permiso denegado.'}, status=403)

        request.user = user
        return super().dispatch(request, *args, **kwargs)



class RolDetailView(AdminRequiredView):
    """
    GET    /api/roles/<role_id>    -> Detalle de un rol
    DELETE /api/roles/<role_id>    -> Elimina un rol
    Solo accesible por administradores.
    """
    def get(self, request, role_id):
        try:
            rol = Rol.objects.get(id=role_id)
            return JsonResponse({'rol': {'id': rol.id, 'nombre': rol.nombre}}, status=200)
        except Rol.DoesNotExist:
            return JsonResponse({'error': 'Rol no encontrado.'}, status=404)

    def delete(self, request, role_id):
        try:
            rol = Rol.objects.get(id=role_id)
            rol.delete()
            return JsonResponse({'message': 'Rol eliminado correctamente.'}, status=200)
        except Rol.DoesNotExist:
            return JsonResponse({'error': 'Rol no encontrado.'}, status=404)
        except Exception as e:
            return JsonResponse({'error': f'No se pudo eliminar el rol: {e}'}, status=500)


class RolesView(AdminRequiredView):
    """
    GET  /api/roles    -> Lista todos los roles
    POST /api/roles    -> Crea un nuevo rol
    Solo accesible por administradores.
    """
    def get(self, request):
        roles = list(Rol.objects.values('id', 'nombre'))
        return JsonResponse({'roles': roles}, status=200)

    def post(self, request):
        try:
            data = json.loads(request.body)
            nombre = data.get('nombre')
            if not nombre:
                return JsonResponse({'error': 'Nombre de rol es requerido.'}, status=400)
            rol = Rol.objects.create(nombre=nombre)
            return JsonResponse({'message': 'Rol creado.', 'rol_id': rol.id}, status=201)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)
        except IntegrityError:
            return JsonResponse({'error': 'Ya existe un rol con ese nombre.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)


class AsignarRolView(AdminRequiredView):
    """
    PUT /api/usuarios/<usuario_id>/rol    -> Asigna un rol a un usuario
    Solo accesible por administradores.
    """
    def put(self, request, usuario_id):
        try:
            data = json.loads(request.body)
            rol_id = data.get('rol_id')
            if not rol_id:
                return JsonResponse({'error': 'rol_id es requerido.'}, status=400)

            usuario = Usuario.objects.get(id=usuario_id)
            rol = Rol.objects.get(id=rol_id)
            usuario.rol = rol
            usuario.save()
            return JsonResponse({'message': 'Rol asignado correctamente.'}, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)
        except Rol.DoesNotExist:
            return JsonResponse({'error': 'Rol no encontrado.'}, status=404)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)


class UsuariosView(AdminRequiredView):
    """
    GET  /api/usuarios    -> Lista todos los usuarios
    POST /api/usuarios    -> Crea un nuevo usuario (solo admin)
    """
    def get(self, request):
        qs = Usuario.objects.select_related('rol').all().values(
            'id', 'nombre', 'email', 'cedula', 'telefono',
            'direccion', 'rol__nombre', 'latitud', 'longitud',
            'fecha_registro', 'is_active'
        )
        usuarios = []
        for u in qs:
            usuarios.append({
                'id': u['id'],
                'nombre': u['nombre'],
                'email': u['email'],
                'cedula': u['cedula'],
                'telefono': u['telefono'],
                'direccion': u['direccion'],
                'rol': u['rol__nombre'],
                'latitud': u['latitud'],
                'longitud': u['longitud'],
                'fecha_registro': u['fecha_registro'].isoformat(),
                'is_active': u['is_active'],
            })
        return JsonResponse({'usuarios': usuarios}, status=200)

    def post(self, request):
        try:
            data = json.loads(request.body)
            nombre = data.get('nombre')
            cedula = data.get('cedula')
            telefono = data.get('telefono')
            direccion = data.get('direccion')
            email = data.get('email')
            password = data.get('password')
            lat = data.get('latitud')
            lng = data.get('longitud')
            rol_id = data.get('rol_id')

            if not all([nombre, cedula, telefono, direccion, email, password, rol_id]):
                return JsonResponse({'error': 'Todos los campos, incluido rol_id, son requeridos.'}, status=400)
            if lat is None or lng is None:
                return JsonResponse({'error': 'Ubicación requerida.'}, status=400)

            if Usuario.objects.filter(email=email).exists():
                return JsonResponse({'error': 'Correo ya registrado.'}, status=400)

            try:
                rol_obj = Rol.objects.get(id=rol_id)
            except Rol.DoesNotExist:
                return JsonResponse({'error': 'Rol no encontrado.'}, status=404)

            usuario = Usuario.objects.create(
                nombre=nombre,
                cedula=cedula,
                telefono=telefono,
                direccion=direccion,
                email=email,
                password=make_password(password),
                rol=rol_obj,
                latitud=float(lat),
                longitud=float(lng),
            )

            return JsonResponse({'message': 'Usuario creado correctamente.', 'usuario_id': usuario.id}, status=201)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)
        except IntegrityError:
            return JsonResponse({'error': 'Correo o cédula ya en uso.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)


class UsuarioDetailView(AdminRequiredView):
    """
    GET    /api/usuarios/<id>    -> Detalle de un usuario
    DELETE /api/usuarios/<id>    -> Elimina un usuario
    Solo accesible por administradores.
    """
    def get(self, request, usuario_id):
        try:
            usuario = Usuario.objects.get(id=usuario_id)
            return JsonResponse({
                'usuario': {
                    'id': usuario.id,
                    'nombre': usuario.nombre,
                    'email': usuario.email,
                    'cedula': usuario.cedula,
                    'telefono': usuario.telefono,
                    'direccion': usuario.direccion,
                    'rol': usuario.rol.nombre if usuario.rol else None,
                    'latitud': usuario.latitud,
                    'longitud': usuario.longitud,
                    'fecha_registro': usuario.fecha_registro.isoformat(),
                    'is_active': usuario.is_active,
                }
            }, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)

    def delete(self, request, usuario_id):
        try:
            usuario = Usuario.objects.get(id=usuario_id)
            usuario.delete()
            return JsonResponse({'message': 'Usuario eliminado correctamente.'}, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)
        except Exception as e:
            return JsonResponse({'error': f'No se pudo eliminar el usuario: {e}'}, status=500)
        
    def put(self, request, usuario_id):
        try:
            data = json.loads(request.body)
            usuario = Usuario.objects.get(id=usuario_id)
            for field in ['nombre','cedula','telefono','direccion','email','latitud','longitud','is_active']:
                if field in data:
                    setattr(usuario, field, data[field])
            usuario.save()
            return JsonResponse({'message': 'Usuario actualizado correctamente.'}, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)
        except IntegrityError:
            return JsonResponse({'error': 'El correo o la cédula ya están en uso.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)


@method_decorator(csrf_exempt, name='dispatch')
class RegistroUsuarioView(View):
    """
    POST /api/register -> Registro público (asigna rol por defecto id=3),
                         si es admin puede pasar rol_id para override.
    """
    def post(self, request):
        try:
            data = json.loads(request.body)
            nombre = data.get('nombre')
            cedula = data.get('cedula')
            telefono = data.get('telefono')
            direccion = data.get('direccion')
            email = data.get('email')
            password = data.get('password')
            lat = data.get('latitud')
            lng = data.get('longitud')
            rol_id = data.get('rol_id') 

            if not all([nombre, cedula, telefono, direccion, email, password]):
                return JsonResponse({'error': 'Todos los campos son requeridos.'}, status=400)
            if lat is None or lng is None:
                return JsonResponse({'error': 'Ubicación requerida.'}, status=400)

            if Usuario.objects.filter(email=email).exists():
                return JsonResponse({'error': 'Correo ya registrado.'}, status=400)

            rol_obj = None
            auth = request.headers.get('Authorization', '')
            if auth.startswith('Bearer '):
                try:
                    pl = jwt.decode(auth.split()[1], settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
                    caller = Usuario.objects.get(id=pl['user_id'])
                    if caller.rol and caller.rol.nombre == 'Administrador' and rol_id:  
                        rol_obj = Rol.objects.get(id=rol_id)  
                except Exception:
                    pass

            if not rol_obj: 
                try:
                    rol_obj = Rol.objects.get(id=3)
                except Rol.DoesNotExist:
                    return JsonResponse({'error': 'Rol por defecto no configurado.'}, status=500)

            usuario = Usuario.objects.create(
                nombre=nombre,
                cedula=cedula,
                telefono=telefono,
                direccion=direccion,
                email=email,
                password=make_password(password),
                rol=rol_obj,
                latitud=float(lat),
                longitud=float(lng),
            )

            return JsonResponse({'message': 'Usuario registrado correctamente.', 'usuario_id': usuario.id}, status=201)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)



@method_decorator(csrf_exempt, name='dispatch')
class LoginUsuarioView(View):
    def post(self, request):
        try:
            data     = json.loads(request.body)
            email    = data.get('email')
            password = data.get('password')

            if not all([email, password]):
                return JsonResponse({'error': 'Email y contraseña son requeridos.'}, status=400)

            try:
                usuario = Usuario.objects.get(email=email)
            except Usuario.DoesNotExist:
                return JsonResponse({'error': 'Credenciales inválidas.'}, status=401)

            if not check_password(password, usuario.password):
                return JsonResponse({'error': 'Credenciales inválidas.'}, status=401)
            if not usuario.is_active:
                return JsonResponse({'error': 'Usuario inactivo.'}, status=403)

            payload = {
                'user_id': usuario.id,
                'exp': datetime.utcnow() + timedelta(hours=getattr(settings, 'JWT_ACCESS_TOKEN_EXPIRE_HOURS', 24))
            }
            token = jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)

            return JsonResponse({
                'message': 'Login exitoso.',
                'token': token,
                'usuario': {
                    'id': usuario.id,
                    'nombre': usuario.nombre,
                    'email': usuario.email,
                    'rol': usuario.rol.nombre if usuario.rol else None,
                    'latitud': usuario.latitud,
                    'longitud': usuario.longitud,
                    'fecha_registro': usuario.fecha_registro.isoformat(),
                    'is_active': usuario.is_active,
                }
            }, status=200)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)


@method_decorator(csrf_exempt, name='dispatch')
class ProfileUsuarioView(View):
    def get(self, request):
        auth = request.headers.get('Authorization', '')
        if not auth.startswith('Bearer '):
            return JsonResponse({'error': 'Token no proporcionado.'}, status=401)

        try:
            payload = jwt.decode(auth.split()[1], settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
            usuario = Usuario.objects.get(id=payload['user_id'])
        except jwt.ExpiredSignatureError:
            return JsonResponse({'error': 'Token expirado.'}, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({'error': 'Token inválido.'}, status=401)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)

        return JsonResponse({'usuario': {
            'id': usuario.id,
            'nombre': usuario.nombre,
            'cedula': usuario.cedula,
            'telefono': usuario.telefono,
            'direccion': usuario.direccion,
            'email': usuario.email,
            'rol': usuario.rol.nombre if usuario.rol else None,
            'latitud': usuario.latitud,
            'longitud': usuario.longitud,
            'is_active': usuario.is_active,
            'fecha_registro': usuario.fecha_registro.isoformat()
        }}, status=200)


@method_decorator(csrf_exempt, name='dispatch')
class EditProfileUsuarioView(View):
    def put(self, request):
        auth = request.headers.get('Authorization', '')
        if not auth.startswith('Bearer '):
            return JsonResponse({'error': 'Token no proporcionado.'}, status=401)

        try:
            payload = jwt.decode(auth.split()[1], settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
            usuario = Usuario.objects.get(id=payload['user_id'])
        except jwt.ExpiredSignatureError:
            return JsonResponse({'error': 'Token expirado.'}, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({'error': 'Token inválido.'}, status=401)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)

        try:
            data = json.loads(request.body)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)

        for field in ['nombre', 'cedula', 'telefono', 'direccion', 'email', 'latitud', 'longitud']:
            if field in data:
                setattr(usuario, field, data[field])

        try:
            usuario.save()
        except IntegrityError:
            return JsonResponse({'error': 'El correo o la cédula ya están en uso.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

        return JsonResponse({'message': 'Perfil actualizado correctamente.'}, status=200)
    

class AuthRequiredView(View):
    """
    Base view que exime CSRF y requiere un JWT válido
    para cualquier usuario autenticado.
    """
    @method_decorator(csrf_exempt)
    def dispatch(self, request, *args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return JsonResponse({'error': 'Token no proporcionado.'}, status=401)
        token = auth_header.split()[1]
        try:
            payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        except jwt.ExpiredSignatureError:
            return JsonResponse({'error': 'Token expirado.'}, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({'error': 'Token inválido.'}, status=401)

        try:
            user = Usuario.objects.get(id=payload['user_id'])
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)

        request.user = user
        return super().dispatch(request, *args, **kwargs)


@method_decorator(csrf_exempt, name='dispatch')
class ClasificacionesView(AuthRequiredView):
    """
    GET  /api/clasificaciones   -> Lista todas las clasificaciones (cualquier usuario autenticado)
    POST /api/clasificaciones   -> Crea una nueva clasificación (sólo admin)
    """
    def get(self, request):
        qs = ClasificacionDenuncia.objects.all().values('id', 'nombre')
        return JsonResponse({'clasificaciones': list(qs)}, status=200)

    def post(self, request):
        # Sólo admin
        if not request.user.rol or request.user.rol.nombre != 'Administrador':
            return JsonResponse({'error': 'Permiso denegado.'}, status=403)

        try:
            data = json.loads(request.body)
            nombre = data.get('nombre')
            if not nombre:
                return JsonResponse({'error': 'El nombre es requerido.'}, status=400)

            clas = ClasificacionDenuncia.objects.create(nombre=nombre)
            return JsonResponse({'message': 'Clasificación creada.', 'id': clas.id}, status=201)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)
        except IntegrityError:
            return JsonResponse({'error': 'Ya existe esa clasificación.'}, status=400)


@method_decorator(csrf_exempt, name='dispatch')
class ClasificacionDetailView(AuthRequiredView):
    """
    GET    /api/clasificaciones/<pk>  -> Detalle de clasificación (usuario autenticado)
    PUT    /api/clasificaciones/<pk>  -> Edita el nombre (sólo admin)
    DELETE /api/clasificaciones/<pk>  -> Elimina la clasificación (sólo admin)
    """
    def get(self, request, pk):
        try:
            c = ClasificacionDenuncia.objects.get(id=pk)
            return JsonResponse({'id': c.id, 'nombre': c.nombre}, status=200)
        except ClasificacionDenuncia.DoesNotExist:
            return JsonResponse({'error': 'Clasificación no encontrada.'}, status=404)

    def put(self, request, pk):
        # Sólo admin
        if not request.user.rol or request.user.rol.nombre != 'Administrador':
            return JsonResponse({'error': 'Permiso denegado.'}, status=403)

        try:
            data = json.loads(request.body)
            nombre = data.get('nombre')
            if not nombre:
                return JsonResponse({'error': 'El nombre es requerido.'}, status=400)

            c = ClasificacionDenuncia.objects.get(id=pk)
            c.nombre = nombre
            c.save()
            return JsonResponse({'message': 'Clasificación actualizada.'}, status=200)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON inválido.'}, status=400)
        except ClasificacionDenuncia.DoesNotExist:
            return JsonResponse({'error': 'Clasificación no encontrada.'}, status=404)
        except IntegrityError:
            return JsonResponse({'error': 'Ya existe esa clasificación.'}, status=400)

    def delete(self, request, pk):
        # Sólo admin
        if not request.user.rol or request.user.rol.nombre != 'Administrador':
            return JsonResponse({'error': 'Permiso denegado.'}, status=403)

        try:
            ClasificacionDenuncia.objects.get(id=pk).delete()
            return JsonResponse({'message': 'Clasificación eliminada.'}, status=200)
        except ClasificacionDenuncia.DoesNotExist:
            return JsonResponse({'error': 'Clasificación no encontrada.'}, status=404)
            

@method_decorator(csrf_exempt, name='dispatch')
class DenunciasView(AuthRequiredView):
    """
    GET  /api/denuncias    -> Lista todas las denuncias
    POST /api/denuncias    -> Crea una nueva denuncia
    """
    def get(self, request):
        qs = Denuncia.objects.select_related('clasificacion', 'otra_clasificacion')\
                              .prefetch_related('imagenes')\
                              .order_by('-fecha', '-hora')
        data = []
        for d in qs:
            data.append({
                'id': d.id,
                'descripcion': d.descripcion,
                'fecha': d.fecha.isoformat(),
                'hora': d.hora.strftime('%H:%M') if d.hora else None,
                'clasificacion': d.clasificacion.nombre if d.clasificacion else None,
                'otra_clasificacion': d.otra_clasificacion.nombre if d.otra_clasificacion else None,
                'ubicacion_latitud': d.ubicacion_latitud,
                'ubicacion_longitud': d.ubicacion_longitud,
                'imagenes': [request.build_absolute_uri(img.imagen.url) for img in d.imagenes.all()],
            })
        return JsonResponse({'denuncias': data}, status=200)

    def post(self, request):
        try:
            descripcion = request.POST.get('descripcion')
            fecha = request.POST.get('fecha')            
            hora = request.POST.get('hora')         
            clas_id = request.POST.get('clasificacion_id')
            otra_id = request.POST.get('otra_clasificacion_id')
            lat = request.POST.get('ubicacion_latitud')
            lng = request.POST.get('ubicacion_longitud')

            if not all([descripcion, fecha, clas_id, lat, lng]):
                return JsonResponse({'error': 'Faltan campos obligatorios.'}, status=400)
            fecha_obj = datetime.fromisoformat(fecha).date()
            hora_obj = datetime.strptime(hora, '%H:%M').time() if hora else None

            with transaction.atomic():
                d = Denuncia.objects.create(
                    descripcion=descripcion,
                    fecha=fecha_obj,
                    hora=hora_obj,
                    clasificacion_id=int(clas_id),
                    otra_clasificacion_id=int(otra_id) if otra_id else None,
                    ubicacion_latitud=float(lat),
                    ubicacion_longitud=float(lng),
                )
                for f in request.FILES.getlist('imagenes'):
                    ImagenDenuncia.objects.create(denuncia=d, imagen=f)

            return JsonResponse({'message': 'Denuncia creada.', 'id': d.id}, status=201)
        except ClasificacionDenuncia.DoesNotExist:
            return JsonResponse({'error': 'Clasificación inválida.'}, status=400)
        except ValueError as ve:
            return JsonResponse({'error': f'Formato inválido: {ve}'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)


@method_decorator(csrf_exempt, name='dispatch')
class DenunciaDetailView(AuthRequiredView):
    """
    GET    /api/denuncias/<pk>  -> Detalle de una denuncia
    PUT    /api/denuncias/<pk>  -> Actualiza datos de la denuncia
    DELETE /api/denuncias/<pk>  -> Elimina la denuncia
    """
    def get(self, request, pk):
        try:
            d = Denuncia.objects.select_related('clasificacion','otra_clasificacion')\
                                .prefetch_related('imagenes')\
                                .get(id=pk)
            return JsonResponse({
                'id': d.id,
                'descripcion': d.descripcion,
                'fecha': d.fecha.isoformat(),
                'hora': d.hora.isoformat() if d.hora else None,
                'clasificacion': d.clasificacion.nombre if d.clasificacion else None,
                'otra_clasificacion': d.otra_clasificacion.nombre if d.otra_clasificacion else None,
                'ubicacion_latitud': d.ubicacion_latitud,
                'ubicacion_longitud': d.ubicacion_longitud,
                'imagenes': [request.build_absolute_uri(img.imagen.url) for img in d.imagenes.all()],
            }, status=200)
        except Denuncia.DoesNotExist:
            return JsonResponse({'error': 'Denuncia no encontrada.'}, status=404)

    def put(self, request, pk):
        try:
            data = json.loads(request.body)
            d = Denuncia.objects.get(id=pk)
            for field in ['descripcion','fecha','hora','clasificacion_id',
                          'otra_clasificacion_id','ubicacion_latitud','ubicacion_longitud']:
                if field in data:
                    val = data[field]
                    if field == 'fecha':
                        setattr(d, field, datetime.fromisoformat(val).date())
                    elif field == 'hora' and val:
                        setattr(d, field, datetime.fromisoformat(val).time())
                    else:
                        setattr(d, field.replace('_id',''), val if not field.endswith('_id') else int(val))
            d.save()
            return JsonResponse({'message': 'Denuncia actualizada.'}, status=200)
        except Denuncia.DoesNotExist:
            return JsonResponse({'error': 'Denuncia no encontrada.'}, status=404)
        except (ValueError, IntegrityError) as e:
            return JsonResponse({'error': str(e)}, status=400)

    def delete(self, request, pk):
        try:
            Denuncia.objects.get(id=pk).delete()
            return JsonResponse({'message': 'Denuncia eliminada.'}, status=200)
        except Denuncia.DoesNotExist:
            return JsonResponse({'error': 'Denuncia no encontrada.'}, status=404)