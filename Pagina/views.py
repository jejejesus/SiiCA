from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth import authenticate, login
from django.contrib import messages


# Create your views here.


# Inicio de Sesion
def inicio_sesion(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('index')  # Redirige a la página deseada después de iniciar sesión
        else:
            messages.error(request, 'Credenciales inválidas. Inténtalo nuevamente.')

    return render(request, 'InicioSesion.html')

@login_required
def index(request):
    user = request.user
    if user.groups.filter(name='Alumnos').exists():  # Si el usuario es un alumno
        return redirect('alumnos_principal')
    elif user.groups.filter(name='Coordinadores').exists():  # Si el usuario es un miembro
        return redirect('coordinadores_principal')
    elif user.groups.filter(name='Miembros').exists():  # Si el usuario es un miembro
        return redirect('miembros_principal')
    elif user.groups.filter(name='Secretario').exists():  # Si el usuario es un coordinador
        return redirect('miembros_principal')
    elif user.groups.filter(name='Presidente').exists():  # Si el usuario es un coordinador
        return redirect('miembros_principal')
    else:  # Si no tiene un rol específico, redirigir a una página genérica o mostrar un mensaje de error
        return render(request, 'Error_401.html')

# Principales

def error_404(request, exception=None):
    context = {}
    return render(request,'Error_404.html', context)
def error_401(request):
    return render(request,'Error_401.html')
@login_required
def alumnos_principal(request):
    user = request.user
    if user.groups.filter(name='Alumnos').exists():
        return render(request, 'Alumnos.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def coordinadores_principal(request):
    user = request.user
    if user.groups.filter(name='Coordinadores').exists():
        return render(request, 'Coordinadores.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def miembros_principal(request):
    user = request.user
    if user.groups.filter(name='Miembros').exists():
        return render(request, 'Miembros.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def secretario_principal(request):
    user = request.user
    if user.groups.filter(name='Secretario').exists():
        return render(request, 'Secretario_Tecnico/Secretario_Tecnico.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def presidente_principal(request):
    user = request.user
    if user.groups.filter(name='Presidente').exists():
        return render(request, 'Presidente/Presidente.html')
    else:
        return render(request, 'Error_401.html')

# Alumnos
@login_required
def alumno_consulta(request):
    user = request.user
    if user.groups.filter(name='Alumnos').exists():
        return render(request, 'Alumnos/Consulta_Solicitud.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def alumnos_cuenta(request):
    user = request.user
    if user.groups.filter(name='Alumnos').exists():
        return render(request, 'Alumnos/Cuenta.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def alumnos_nueva(request):
    user = request.user
    if user.groups.filter(name='Alumnos').exists():
        return render(request, 'Alumnos/Nueva_Solicitud.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def alumnos_solicitud(request):
    user = request.user
    if user.groups.filter(name='Alumnos').exists():
        return render(request, 'Alumnos/Solicitud.html')
    else:
        return render(request, 'Error_401.html')

# Coordinadores
@login_required
def coordinador_consulta(request):
    user = request.user
    if user.groups.filter(name='Coordinadores').exists():
        return render(request, 'Coordinadores/Consulta_Solicitud.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def coordinador_cuenta(request):
    user = request.user
    if user.groups.filter(name='Coordinadores').exists():
        return render(request, 'Coordinadores/Cuenta.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def coordinador_evaluacion(request):
    user = request.user
    if user.groups.filter(name='Coordinadores').exists():
        return render(request, 'Coordinadores/Nueva_Evaluacion.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def coordinador_solicitud(request):
    user = request.user
    if user.groups.filter(name='Coordinadores').exists():
        return render(request, 'Coordinadores/Solicitud.html')
    else:
        return render(request, 'Error_401.html')

# Miembros
@login_required
def miembro_consulta(request):
    user = request.user
    if user.groups.filter(name='Miembros').exists():
        return render(request, 'Miembros/Consulta_Solicitud.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def miembro_cuenta(request):
    user = request.user
    if user.groups.filter(name='Miembros').exists():
        return render(request, 'Miembros/Cuenta.html')
    else:
        return render(request, 'Error_401.html')
@login_required
def miembro_solicitud(request):
    user = request.user
    if user.groups.filter(name='Miembros').exists():
        return render(request, 'Miembros/Solicitud.html')
    else:
        return render(request, 'Error_401.html')

