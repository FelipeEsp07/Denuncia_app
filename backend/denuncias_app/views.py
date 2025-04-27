# aplicacion1/views.py

from django.http import JsonResponse
from .models import Usuario, Rol
from django.contrib.auth.hashers import make_password, check_password
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.views import View
from datetime import datetime, timedelta
import json
import jwt
from django.conf import settings
from django.db import IntegrityError

def role_required(*allowed_roles):
    def decorator(fn):
        def wrapper(self, request, *args, **kwargs):
            auth = request.headers.get('Authorization', '')
            if not auth.startswith('Bearer '):
                return JsonResponse({'error': 'Token no proporcionado.'}, status=401)
            token = auth.split()[1]
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

            if not user.rol or user.rol.nombre not in allowed_roles:
                return JsonResponse({'error': 'Permiso denegado.'}, status=403)

            request.user = user
            return fn(self, request, *args, **kwargs)
        return wrapper
    return decorator


@method_decorator(csrf_exempt, name='dispatch')
class RolesView(View):
    @method_decorator(role_required('Administrador'))
    def get(self, request):
        roles = list(Rol.objects.values('id', 'nombre'))
        return JsonResponse({'roles': roles}, status=200)

    @method_decorator(role_required('Administrador'))
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
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)


@method_decorator(csrf_exempt, name='dispatch')
class AsignarRolView(View):
    @method_decorator(role_required('Administrador'))
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


@method_decorator(csrf_exempt, name='dispatch')
class RegistroUsuarioView(View):
    def post(self, request):
        try:
            data      = json.loads(request.body)
            nombre    = data.get('nombre')
            cedula    = data.get('cedula')
            telefono  = data.get('telefono')
            direccion = data.get('direccion')
            email     = data.get('email')
            password  = data.get('password')
            lat       = data.get('latitud')
            lng       = data.get('longitud')

            # Validaciones básicas
            if not all([nombre, cedula, telefono, direccion, email, password]):
                return JsonResponse({'error': 'Todos los campos son requeridos.'}, status=400)
            if lat is None or lng is None:
                return JsonResponse({'error': 'Ubicación (latitud y longitud) requerida.'}, status=400)

            if Usuario.objects.filter(email=email).exists():
                return JsonResponse({'error': 'Ya existe un usuario con este correo electrónico.'}, status=400)

            try:
                rol_obj = Rol.objects.get(id=3)
            except Rol.DoesNotExist:
                return JsonResponse({'error': 'Rol por defecto no configurado.'}, status=500)

            auth = request.headers.get('Authorization', '')
            if auth.startswith('Bearer '):
                try:
                    payload = jwt.decode(auth.split()[1], settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
                    caller = Usuario.objects.get(id=payload['user_id'])
                    if caller.rol and caller.rol.nombre.lower() == 'administrador':
                        if data.get('rol_id'):
                            rol_obj = Rol.objects.get(id=data['rol_id'])
                except Exception:
                    pass

            usuario = Usuario.objects.create(
                nombre     = nombre,
                cedula     = cedula,
                telefono   = telefono,
                direccion  = direccion,
                email      = email,
                password   = make_password(password),
                rol        = rol_obj,
                latitud    = float(lat),
                longitud   = float(lng),
            )

            return JsonResponse({
                'message':    'Usuario registrado correctamente.',
                'usuario_id': usuario.id
            }, status=201)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Formato JSON inválido.'}, status=400)
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

            # Generar JWT
            payload = {
                'user_id': usuario.id,
                'exp': datetime.utcnow() + timedelta(hours=getattr(settings, 'JWT_ACCESS_TOKEN_EXPIRE_HOURS', 24))
            }
            token = jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)

            return JsonResponse({
                'message': 'Login exitoso.',
                'token': token,
                'usuario': {
                    'id':             usuario.id,
                    'nombre':         usuario.nombre,
                    'email':          usuario.email,
                    'rol':            usuario.rol.nombre if usuario.rol else None,
                    'latitud':        usuario.latitud,
                    'longitud':       usuario.longitud,
                    'fecha_registro': usuario.fecha_registro.isoformat(),
                    'is_active':      usuario.is_active,
                }
            }, status=200)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Formato JSON inválido.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': f'Error interno: {e}'}, status=500)


@method_decorator(csrf_exempt, name='dispatch')
class ProfileUsuarioView(View):
    def get(self, request):
        auth = request.headers.get('Authorization', '')
        if not auth.startswith('Bearer '):
            return JsonResponse({'error': 'Token de autenticación no proporcionado.'}, status=401)

        try:
            payload = jwt.decode(auth.split()[1], settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
            usuario = Usuario.objects.get(id=payload['user_id'])
        except jwt.ExpiredSignatureError:
            return JsonResponse({'error': 'El token ha expirado.'}, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({'error': 'Token inválido.'}, status=401)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)

        return JsonResponse({
            'usuario': {
                'id':             usuario.id,
                'nombre':         usuario.nombre,
                'cedula':         usuario.cedula,
                'telefono':       usuario.telefono,
                'direccion':      usuario.direccion,
                'email':          usuario.email,
                'rol':            usuario.rol.nombre if usuario.rol else None,
                'latitud':        usuario.latitud,
                'longitud':       usuario.longitud,
                'is_active':      usuario.is_active,
                'fecha_registro': usuario.fecha_registro.isoformat(),
            }
        }, status=200)


@method_decorator(csrf_exempt, name='dispatch')
class EditProfileUsuarioView(View):
    def put(self, request):
        auth = request.headers.get('Authorization', '')
        if not auth.startswith('Bearer '):
            return JsonResponse({'error': 'Token de autenticación no proporcionado.'}, status=401)

        try:
            payload = jwt.decode(auth.split()[1], settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
            usuario = Usuario.objects.get(id=payload['user_id'])
        except jwt.ExpiredSignatureError:
            return JsonResponse({'error': 'El token ha expirado.'}, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({'error': 'Token inválido.'}, status=401)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado.'}, status=404)

        try:
            data = json.loads(request.body)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Formato JSON inválido.'}, status=400)

        for field in ['nombre', 'cedula', 'telefono', 'direccion', 'email', 'latitud', 'longitud']:
            if field in data:
                setattr(usuario, field, data[field])

        try:
            usuario.save()
        except IntegrityError:
            return JsonResponse({'error': 'El correo o la cédula ya están en uso por otro usuario.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': f'Error guardando perfil: {e}'}, status=500)

        return JsonResponse({'message': 'Perfil actualizado correctamente.'}, status=200)
