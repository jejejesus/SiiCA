create database SiiCA_ComiteAcademico
go
use SiiCA_ComiteAcademico
go

-- CREACION DE TABLAS

create table Instituto
(
	Clave int not null,
	Nombre nvarchar(50) unique not null,
	Direccion nvarchar(50) unique not null,
	PaginaWeb nvarchar(50) not null,
)
go
create table Usuario
(
	Numero int not null,
	NombreUsuario nvarchar (50) unique not null,
	Contrasena nvarchar (30) not null,
)
go
create table Miembro
(
	NoEmp int not null,
	Nombre nvarchar(50) not null,
	ApellidoPaterno nvarchar (50) null,
	ApellidoMaterno nvarchar (50) null,
	Telefono varchar (20) unique not null,
	Tipo char(1) not null,
	CorreoInst nvarchar (50) unique not null,
	Instituto int not null,
	Usuario int unique not null,
)
go
create table Sesion
(
	Fecha date not null,
	Hora time not null,
	Lugar nvarchar (50) not null,
)
go
create table Asistencia 
(
	Fecha date not null,
	Hora time not null,
	Miembro int not null,
)
go
create table Coordinador
(
	NoEmp int not null,
	Nombre nvarchar(50) not null,
	ApellidoPaterno nvarchar (50) null,
	ApellidoMaterno nvarchar (50) null,
	Telefono varchar (20) unique not null,
	CorreoInst nvarchar (50) unique not null,
	Instituto int not null,
	Usuario int unique not null,
)
go
create table Carrera
(
	Codigo int not null,
	Nombre nvarchar(80) not null,
	Coordinador int not null,
)
go
create table Alumno
(
	NoControl int not null,
	Nombre nvarchar(50) not null,
	ApellidoPaterno nvarchar (50) null,
	ApellidoMaterno nvarchar (50) null,
	Semestre int not null,
	Telefono varchar (20) unique not null,
	CorreoInst nvarchar (50) unique not null,
	Usuario int unique not null,
	Carrera int not null,
)
go
create table Solicitud
(
	Numero int not null,
	Alumno int not null,
	Asunto int not null,
	Fecha date not null,
	Motivos nvarchar (250),
	EvaluacionInicial nvarchar (250),
)
go
create table Asunto
(
	Codigo int not null,
	Descripcion nvarchar(250) unique not null,
)
go
create table Sustento
(
	Folio int not null,
	Solicitud int not null,
	Documento varbinary (MAX) not null,
)
go
create table Estatus
(
	Solicitud int not null,
	Fecha date not null,
	Hora time not null,
	Usuario int not null,
	Estatus char(1) not null,
)
go
create table Estatuses
(
	Clave char(1) not null,
	Descripcion nvarchar(10) not null
)
go

-- CREACION DE PRIMARY KEYS
alter table Sustento add constraint PK_Sustento_FolioSolicitud primary key (Folio, Solicitud)
alter table Estatus add constraint PK_Estatus_FechaHoraSolicitud primary key (Fecha, Hora, Solicitud)
alter table Alumno add constraint PK_Alumno_NoControl primary key (NoControl)
alter table Usuario add constraint PK_Usuario_Numero primary key (Numero)
alter table Instituto add constraint PK_Instituto_Clave primary key (Clave)
alter table Sesion add constraint PK_Sesion_FechaHora primary key (Fecha, Hora)
alter table Miembro add constraint PK_Miembro_NoEmp primary key (NoEmp)
alter table Asunto add constraint PK_Asuntos_Codigo primary key (Codigo)
alter table Carrera add constraint PK_Carrera_Codigo primary key (Codigo)
alter table Coordinador add constraint PK_Coordinador_NoEmp primary key (NoEmp)
alter table Asistencia add constraint PK_Asistencia_FechaNoEmp primary key (Fecha, Hora, Miembro)
alter table Solicitud add constraint PK_Solicitud_Numero primary key (Numero)
alter table Estatuses add constraint PK_Estatuses_Codigo primary key (Clave)
go

-- CREACION DE FOREIGN KEYS

alter table Alumno add constraint FK_Alumno_Usuario foreign key (Usuario) references Usuario (Numero),
					   constraint FK_Alumno_Carrera foreign key (Carrera) references Carrera (Codigo)
alter table Coordinador add constraint FK_Coordinador_Instituto foreign key (Instituto) references Instituto (Clave),
							constraint FK_Coordinador_Usuario foreign key (Usuario) references Usuario (Numero)
alter table Carrera add constraint FK_Carrera_Coordinador foreign key (Coordinador) references Coordinador (NoEmp)
alter table Estatus add constraint FK_Estatus_Solicitud foreign key (Solicitud) references Solicitud (Numero),
						constraint FK_Estatus_Usuario foreign key (Usuario) references Usuario(Numero)
alter table Sustento add constraint FK_Sustento foreign key (Solicitud) references Solicitud (Numero)
alter table Solicitud add constraint FK_Solicitud_Alumno foreign key (Alumno) references Alumno (NoControl),
						 constraint FK_Solicitud_Asunto foreign key (Asunto) references Asunto (Codigo)
alter table Asistencia add constraint FK_Asistencia_SesionFecha foreign key (Fecha) references Sesion (Fecha),
						   constraint FK_Asistencia_SesionHora foreign key (Hora) references Sesion (Hora),
						   constraint FK_Asistencia_Miembro foreign key (Miembro) references Miembro (NoEmp)
alter table Miembro add constraint FK_Empleado_Instituto foreign key (Instituto) references Instituto (Clave),
						constraint FK_Empleado_Usuario foreign key (Usuario) references Usuario (Numero)
alter table Estatus add constraint FK_Estatus_Estatuses foreign key (Estatus) references Estatuses (Clave)
go

-- PROCEDIMIENTO PARA INSERTAR REGISTROS

create proc  InsertarUsuario @NombreUsuario nvarchar(50), @Contrasena nvarchar(30), @Numero int output
as
	if exists(select * from Usuario where NombreUsuario = @NombreUsuario)
	begin
		set @Numero = -1
	end
	else
	begin
		select @Numero = MAX(Numero) + 1 from Usuario
		if @Numero is null 
			set @Numero = 1

		insert into Usuario (Numero, NombreUsuario, Contrasena)
		values (@Numero, @NombreUsuario, @Contrasena)
	end
go

ALTER procedure InsertarAlumno @NoControl int , @Nombre nvarchar(50), @ApellidoPaterno nvarchar (50), @ApellidoMaterno nvarchar (50), @Semestre int,
								@Telefono varchar(20), @CorreoInst nvarchar(50), @Carrera int, @NombreUsuario nvarchar(50), @Contrasena nvarchar(30)
as
	declare @Num_Usuario int
	exec InsertarUsuario @NombreUsuario, @Contrasena, @Num_Usuario output

	declare @Repetido bit
	set @Repetido = 0
	if not exists(select NoControl from Alumno where NoControl = @NoControl) set @Repetido = 1
	if not exists(select Telefono from Alumno where Telefono = @Telefono) set @Repetido = 1
	if not exists(select CorreoInst from Alumno where CorreoInst = @CorreoInst) set @Repetido = 1

	if @Repetido = 1
	begin
		raiserror('DATOS REPETIDOS', 16, 1)
		rollback tran
	end
	
	insert into Alumno (NoControl, Nombre, ApellidoPaterno, ApellidoMaterno, Carrera, Semestre, Telefono, CorreoInst, Usuario)
	values (@NoControl, @Nombre, @ApellidoPaterno, @ApellidoMaterno, @Carrera, @Semestre, @Telefono, @CorreoInst, @Num_Usuario)
go


declare @Numero int
exec InsertarUsuario 'jbanuelos', '123456', @Numero
exec InsertarUsuario 'kguerrero', '654321', @Numero
exec InsertarUsuario 'avelazquez', '246810', @Numero
exec InsertarUsuario 'dfelix', '3691215', @Numero
exec InsertarUsuario 'epadilla', '361215', @Numero

select * from Usuario
/*CREATE PROC [dbo].[ArticuloRegistrar] @nombre NVARCHAR(50), @descripcion NVARCHAR(50), @precio NUMERIC(12,2), @existencia INT, @clave INT OUTPUT
AS
	INSERT INTO ARTICULO (Nombre, Descripcion,Precio,Existencia) VALUES (@nombre, @descripcion,@precio,@existencia)
	SELECT @clave = SCOPE_IDENTITY()
GO*/
go

-- DATOS NECESARIOS

insert into Asunto(Codigo, Descripcion) values
 (1, 'Solicitud de baja temporar del semestre'),
 (2, 'Solicitud de baja permanente del semestre'),
 (3, 'Solicitud de baja de materia'),
 (4, 'Solicitud de extensión de periodos para la culminación de la carrera.'),
 (5, 'Pertinencia de las líneas y de los espacios para la investigación.'),
 (6, 'Priorización y asignación de recursos para los proyectos, en términos de su impacto institucional y en el entorno.'),
 (7, 'La incorporación y/o cancelación de prerrequisito de asignaturas.'),
 (8, 'Atención a una inconformidad en asignación de calificación.'),
 (9, 'Solicitud para reingreso al instituto.'),
 (10, 'Designación de un (una) profesor(a) o comisión para evaluación de asignaturas en los casos donde el docente no concluya el curso.'),
 (11, 'Propuesta de profesores(as) para impartir cursos.'),
 (12, 'Propuesta de profesores(as) y horarios en educación no escolarizada a distancia y mixta.'),
 (13, 'Designaciones de asesores internos y externos en el ámbito del proceso de residencia rrofesional.'),
 (14, 'Propuestas de acciones remediales de apoyo a los planes y programas de estudio.')
select * from Asunto order by Codigo

insert into Estatuses(Clave, Descripcion) values
 ('P', 'Pendiente de evaluar'),
 ('E', 'Evaluada'),
 ('F', 'Falta sustento'),
 ('S', 'Pendiente de sesión'),
 ('O', 'Postpuesta'),
 ('A', 'Aprobada'),
 ('N', 'No aprobada')
 select * from Estatuses