"""
URL configuration for SiiCA project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
import Pagina.views as views
from django.urls import path, include
from django.contrib.auth.views import LoginView as inicio, LogoutView as salir

urlpatterns = [
    # Principales
    path('admin/', admin.site.urls),
    path('', views.index, name='index'),
    path('accounts/login/', inicio.as_view(template_name='InicioSesion.html'), name='inicio_sesion'),
    path('logout/', salir.as_view(), name='logout'),
    path('Error_404/', views.error_404, name='error_404'),
    path('Alumnos/', views.alumnos_principal, name='alumnos_principal'),
    path('Coordinadores/', views.coordinadores_principal, name='coordinadores_principal'),
    path('Miembros/', views.miembros_principal, name='miembros_principal'),
    path('Secretario_Tecnico/', views.secretario_principal, name='secretario_principal'),
    path('Presidente/', views.presidente_principal, name='presidente_principal'),

    # Alumnos
    path('Alumnos/Consultar_Solicitudes', views.alumno_consulta, name='alumno_consulta'),
    path('Alumnos/Informacion_Cuenta', views.alumnos_cuenta, name='alumnos_cuenta'),
    path('Alumnos/Nueva_Solicitud', views.alumnos_nueva, name='alumnos_nueva'),
    path('Alumnos/Consulta_Solicitud', views.alumnos_solicitud, name='alumnos_solicitud'),

    # Coordinadores
    path('Coordinadores/Consultar_Solicitudes', views.coordinador_consulta, name='coordinador_consulta'),
    path('Coordinadores/Informacion_Cuenta', views.coordinador_cuenta, name='coordinador_cuenta'),
    path('Coordinadores/Nueva_Evaluacion', views.coordinador_evaluacion, name='coordinador_evaluacion'),
    path('Coordinadores/Consulta_Solicitud', views.coordinador_solicitud, name='coordinador_solicitud'),

    # Miembros
    path('Miembros/Consultar_Solicitudes', views.miembro_consulta, name='miembro_consulta'),
    path('Miembros/Informacion_Cuenta', views.miembro_cuenta, name='miembro_cuenta'),
    path('Miembros/Consulta_Solicitud', views.miembro_solicitud, name='miembro_solicitud'),

    # Secretario Tecnico

    # Presidente
]

handler404 = 'Pagina.views.error_404'
