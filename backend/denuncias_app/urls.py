from django.urls import path
from . import views
from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    path('api/roles', views.RolesView.as_view(), name='roles-list-create'),
    path('api/usuarios/<int:usuario_id>/rol', views.AsignarRolView.as_view(), name='asignar-rol-usuario'),
    path('api/register', views.RegistroUsuarioView.as_view(), name='registro-usuario'),
    path('api/login',    views.LoginUsuarioView.as_view(),    name='login-usuario'),
    path('api/profile',  views.ProfileUsuarioView.as_view(),  name='profile-usuario'),
    path('api/profile/edit', views.EditProfileUsuarioView.as_view(), name='edit-profile-usuario'),

] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)