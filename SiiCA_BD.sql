create database SiiCA_ComiteAcademico;
use SiiCA_ComiteAcademico;

CREATE TABLE Estatuses (
    Clave CHAR(1) NOT NULL,
    Descripcion VARCHAR(20) NOT NULL,
    PRIMARY KEY (Clave)
);

CREATE TABLE Usuario (
    Numero INT NOT NULL,
    NombreUsuario VARCHAR(50) NOT NULL,
    Contrasena VARCHAR(30) NOT NULL,
    PRIMARY KEY (Numero),
    UNIQUE (NombreUsuario)
);

CREATE TABLE Instituto (
    Clave INT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Direccion VARCHAR(50) NOT NULL,
    PaginaWeb VARCHAR(50) NOT NULL,
    PRIMARY KEY (Clave),
    UNIQUE (Nombre),
    UNIQUE (Direccion)
);

CREATE TABLE Coordinador (
    NoEmp INT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoPaterno VARCHAR(50),
    ApellidoMaterno VARCHAR(50),
    Telefono VARCHAR(20) NOT NULL,
    CorreoInst VARCHAR(50) NOT NULL,
    Instituto INT NOT NULL,
    Usuario INT NOT NULL,
    PRIMARY KEY (NoEmp),
    UNIQUE (Telefono),
    UNIQUE (CorreoInst),
    FOREIGN KEY (Instituto) REFERENCES Instituto (Clave),
    FOREIGN KEY (Usuario) REFERENCES Usuario (Numero)
);

CREATE TABLE Carrera (
    Codigo INT NOT NULL,
    Nombre VARCHAR(80) NOT NULL,
    Coordinador INT NOT NULL,
    PRIMARY KEY (Codigo),
    FOREIGN KEY (Coordinador) REFERENCES Coordinador (NoEmp)
);

CREATE TABLE Asunto (
    Codigo INT NOT NULL,
    Descripcion VARCHAR(250) NOT NULL,
    PRIMARY KEY (Codigo),
    UNIQUE (Descripcion)
);

CREATE TABLE Alumno (
    NoControl INT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoPaterno VARCHAR(50),
    ApellidoMaterno VARCHAR(50),
    Semestre INT NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    CorreoInst VARCHAR(50) NOT NULL,
    Usuario INT NOT NULL,
    Carrera INT NOT NULL,
    PRIMARY KEY (NoControl),
    UNIQUE (Telefono),
    UNIQUE (CorreoInst),
    UNIQUE (Usuario),
    FOREIGN KEY (Usuario) REFERENCES Usuario (Numero),
    FOREIGN KEY (Carrera) REFERENCES Carrera (Codigo)
);

CREATE TABLE Miembro (
    NoEmp INT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoPaterno VARCHAR(50),
    ApellidoMaterno VARCHAR(50),
    Telefono VARCHAR(20) NOT NULL,
    Tipo CHAR(1) NOT NULL,
    CorreoInst VARCHAR(50) NOT NULL,
    Instituto INT NOT NULL,
    Usuario INT NOT NULL,
    PRIMARY KEY (NoEmp),
    UNIQUE (Telefono),
    UNIQUE (CorreoInst),
    UNIQUE (Usuario),
    FOREIGN KEY (Instituto) REFERENCES Instituto (Clave),
    FOREIGN KEY (Usuario) REFERENCES Usuario (Numero)
);

CREATE TABLE Sesion (
	Folio INT NOT NULL,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Lugar VARCHAR(50) NOT NULL,
    PRIMARY KEY (Folio),
    INDEX idx_Sesion_Fecha_Hora (Fecha, Hora)
);

CREATE TABLE Asistencia (
    Sesion INT NOT NULL,
    Miembro INT NOT NULL,
    PRIMARY KEY (Sesion, Miembro),
    FOREIGN KEY (Sesion) REFERENCES Sesion (Folio),
    FOREIGN KEY (Miembro) REFERENCES Miembro (NoEmp)
);

CREATE TABLE Solicitud (
    Numero INT NOT NULL,
    Alumno INT NOT NULL,
    Asunto INT NOT NULL,
    Fecha DATE NOT NULL,
    Motivos VARCHAR(250),
    EvaluacionInicial VARCHAR(250),
    PRIMARY KEY (Numero),
    FOREIGN KEY (Alumno) REFERENCES Alumno (NoControl),
    FOREIGN KEY (Asunto) REFERENCES Asunto (Codigo)
);

CREATE TABLE Sustento (
    Folio INT NOT NULL,
    Solicitud INT NOT NULL,
    Documento LONGBLOB NOT NULL,
    PRIMARY KEY (Folio, Solicitud),
    FOREIGN KEY (Solicitud) REFERENCES Solicitud (Numero)
);

CREATE TABLE Estatus (
    Solicitud INT NOT NULL,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Usuario INT NOT NULL,
    Estatus CHAR(1) NOT NULL,
    Sesion INT NULL,
    PRIMARY KEY (Fecha, Hora, Solicitud),
    FOREIGN KEY (Solicitud) REFERENCES Solicitud (Numero),
    FOREIGN KEY (Usuario) REFERENCES Usuario (Numero),
    FOREIGN KEY (Sesion) REFERENCES Sesion (Folio)
);

-- PROCEDIMIENTOS ALMACENADOS

DELIMITER //

CREATE PROCEDURE InsertarUsuario (IN NombreUsuarioParam NVARCHAR(50), IN Contrasena NVARCHAR(30), OUT Numero INT)
BEGIN
    DECLARE NumeroTemp INT;
    
    SELECT MAX(Numero) INTO NumeroTemp FROM Usuario;
    SET Numero = IFNULL(NumeroTemp + 1, 1);
    
    IF EXISTS (SELECT * FROM Usuario WHERE NombreUsuario = NombreUsuarioParam) THEN
        SET Numero = -1;
    ELSE
        INSERT INTO Usuario (Numero, NombreUsuario, Contrasena)
        VALUES (Numero, NombreUsuarioParam, Contrasena);
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE InsertarAlumno(
    IN NoControl INT,
    IN Nombre NVARCHAR(50),
    IN ApellidoPaterno NVARCHAR(50),
    IN ApellidoMaterno NVARCHAR(50),
    IN Semestre INT,
    IN Telefono VARCHAR(20),
    IN CorreoInst NVARCHAR(50),
    IN Carrera INT,
    IN NombreUsuario NVARCHAR(50),
    IN Contrasena NVARCHAR(30)
)
BEGIN
    DECLARE Num_Usuario INT;
    DECLARE Repetido BIT DEFAULT 0;

    -- Verificar si los datos son repetidos
    IF EXISTS (SELECT 1 FROM Alumno WHERE NoControl = NoControl OR Telefono = Telefono OR CorreoInst = CorreoInst) THEN
        SET Repetido = 1;
    END IF;

    -- Insertar el usuario
    IF Repetido = 0 THEN
        CALL InsertarUsuario(NombreUsuario, Contrasena, Num_Usuario);

        -- Verificar si se generó un nuevo número de usuario válido
        IF Num_Usuario IS NULL THEN
            SET Num_Usuario = 1;
        END IF;

        -- Insertar el alumno
        INSERT INTO Alumno (NoControl, Nombre, ApellidoPaterno, ApellidoMaterno, Carrera, Semestre, Telefono, CorreoInst, Usuario)
        VALUES (NoControl, Nombre, ApellidoPaterno, ApellidoMaterno, Carrera, Semestre, Telefono, CorreoInst, Num_Usuario);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DATOS REPETIDOS';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE InsertarCoordinador(
	IN NoEmp INT,
    IN NombreCoordinador NVARCHAR(50),
    IN ApellidoPaterno NVARCHAR(50),
    IN ApellidoMaterno NVARCHAR(50),
    IN Telefono VARCHAR(20),
    IN CorreoInst NVARCHAR(50),
    IN InstitutoID INT,
    IN NombreUsuario NVARCHAR(50),
    IN Contrasena NVARCHAR(30)
)
BEGIN
    DECLARE Num_Usuario INT;
    DECLARE Repetido BIT DEFAULT 0;

    -- Verificar si los datos son repetidos
    IF EXISTS (SELECT 1 FROM Coordinador WHERE Coordinador.NoEmp = NoEmp OR Telefono = Telefono OR CorreoInst = CorreoInst) THEN
        SET Repetido = 1;
    END IF;

    -- Insertar el usuario
    IF Repetido = 0 THEN
        CALL InsertarUsuario(NombreUsuario, Contrasena, Num_Usuario);

        -- Verificar si se generó un nuevo número de usuario válido
        IF Num_Usuario IS NULL THEN
            SET Num_Usuario = 1;
        END IF;

        -- Insertar el alumno
        INSERT INTO Alumno (NoControl, Nombre, ApellidoPaterno, ApellidoMaterno, Carrera, Semestre, Telefono, CorreoInst, Usuario)
        VALUES (NoControl, Nombre, ApellidoPaterno, ApellidoMaterno, Carrera, Semestre, Telefono, CorreoInst, Num_Usuario);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DATOS REPETIDOS';
    END IF;

    -- Insertar el usuario
    IF Repetido = 0 THEN
        CALL InsertarUsuario(NombreUsuario, Contrasena, Num_Usuario);

        -- Verificar si se generó un nuevo número de usuario válido
        IF Num_Usuario IS NULL THEN
            SET Num_Usuario = 1;
        END IF;

    -- Obtener el número de coordinador
    SELECT MAX(NoEmp) + 1 INTO NumCoordinador FROM Coordinador;
    IF NumCoordinador IS NULL THEN
        SET NumCoordinador = 1;
    END IF;

    -- Insertar el coordinador
    INSERT INTO Coordinador (NoEmp, Nombre, ApellidoPaterno, ApellidoMaterno, Telefono, CorreoInst, Instituto, Usuario)
    VALUES (NumCoordinador, NombreCoordinador, ApellidoPaterno, ApellidoMaterno, Telefono, CorreoInst, InstitutoID, NumUsuario);

    SELECT NumCoordinador AS 'CoordinadorID';
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE InsertarMiembro(
    IN NombreMiembro NVARCHAR(50),
    IN ApellidoPaterno NVARCHAR(50),
    IN ApellidoMaterno NVARCHAR(50),
    IN Telefono VARCHAR(20),
    IN Tipo CHAR(1),
    IN CorreoInst NVARCHAR(50),
    IN InstitutoID INT,
    IN NombreUsuario NVARCHAR(50),
    IN Contrasena NVARCHAR(30)
)
BEGIN
    DECLARE NumUsuario INT;
    DECLARE NumMiembro INT;

    -- Insertar el usuario
    CALL InsertarUsuario(NombreUsuario, Contrasena, NumUsuario);

    -- Obtener el número de miembro
    SELECT MAX(NoEmp) + 1 INTO NumMiembro FROM Miembro;
    IF NumMiembro IS NULL THEN
        SET NumMiembro = 1;
    END IF;

    -- Insertar el miembro
    INSERT INTO Miembro (NoEmp, Nombre, ApellidoPaterno, ApellidoMaterno, Telefono, Tipo, CorreoInst, Instituto, Usuario)
    VALUES (NumMiembro, NombreMiembro, ApellidoPaterno, ApellidoMaterno, Telefono, Tipo, CorreoInst, InstitutoID, NumUsuario);

    SELECT NumMiembro AS 'MiembroID';
END //

DELIMITER ;


-- DATOS NECESARIOS

insert into Instituto(Clave, Nombre, Direccion, PaginaWeb) values
 (101 , 'Instituto Tecnológico de Culiacán', 'Juan de Dios Bátiz #310 Pte., Col. Guadalupe', 'https://culiacan.tecnm.mx/'),
 (102 , 'Instituto Tecnológico de Eldorado', 'Av. Tecnológico S/N, Col. Rubén Jaramillo', 'http://www.itseldorado.edu.mx/'),
 (103 , 'Instituto Tecnológico de Querétaro', 'Av. Tecnológico S/N, Col. Centro Histórico', 'https://queretaro.tecnm.mx/'),
 (104 , 'Instituto Tecnológico de Tijuana', 'Calz. Del Tecnológico S/N, Fracc. Tomas Aquino', 'https://www.tijuana.tecnm.mx/');
select * from Instituto;

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
 (14, 'Propuestas de acciones remediales de apoyo a los planes y programas de estudio.');
select * from Asunto order by Codigo;

insert into Estatuses(Clave, Descripcion) values
 ('P', 'Pendiente de evaluar'),
 ('E', 'Evaluada'),
 ('F', 'Falta sustento'),
 ('S', 'Pendiente de sesión'),
 ('O', 'Postpuesta'),
 ('A', 'Aprobada'),
 ('N', 'No aprobada');
 select * from Estatuses;
 
 insert into Usuario(Numero, NombreUsuario, Contrasena) values
  (2, 'e_bajaras', '123456'),
  (3, 'r_amador', '123456'),
  (4, 's_castana', '123456'),
  (5, 'e_cazares', '123456'),
  (6, 'j_beltran', '123456'),
  (7, 'e_juarez', '123456'),
  (8, 'j_palacios', '123456'),
  (9, 'b_patron', '123456');
select * from Usuario;

insert into Coordinador(NoEmp, Nombre, ApellidoPaterno, ApellidoMaterno, Telefono, CorreoInst, Instituto, Usuario) values
 (1001, 'Edna Rocío', 'Barajas', 'Olivas', '6674859367', 'coorsistemas@culiacan.tecnm.mx', 101, 2),
 (1002, 'Rosa Icela', 'Amador', 'Cázares', '6678493826', 'coorindustrial@culiacan.tecnm.mx', 101, 3),
 (1003, 'Segundo', 'Castaña', 'Gallo', '6675463786', 'coorbioquimica@itseldorado.edu.mx', 102, 4),
 (1004, 'Everd Luis', 'Cázares', 'Domínguez', '6678985766', 'coorsistemas@itseldorado.edu.mx', 102, 5),
 (1005, 'Jessica Guadalupe', 'Beltrán', 'Ramírez', '4427684956', 'coorbioquimica@queretaro.tecnm.mx', 103, 6),
 (1006, 'Eliseo', 'Juárez', 'López', '4438675849', 'coorelectronica@queretaro.tecnm.mx', 103, 7),
 (1007, 'Juan Enrique', 'Palacios', 'Quintero', '6648786757', 'cooraeronautica@tijuana.tecnm.m', 104, 8),
 (1008, 'Bertha Lucía', 'Patrón', 'Arellano', '6643546354', 'coormecatronica@tijuana.tecnm.m', 104, 9);
select * from Coordinador;

insert into Carrera(Codigo, Nombre, Coordinador) values
 (10, 'Ingeniería en Sistemas Computacionales', 1001),
 (11, 'Ingeniería en Tecnologías de la Información y Comunicaciones', 1001),
 (12, 'Ingeniería Industrial', 1002),
 (13, 'Ingeniería Bioquímica', 1003),
 (14, 'Ingeniería en Sistemas Computacionales', 1004),
 (15, 'Ingeniería Bioquímica', 1005),
 (16, 'Ingeniería Eléctrica', 1006),
 (17, 'Ingeniería Electrónica', 1006),
 (18, 'Ingeniería Aeronáutica', 1007),
 (19, 'Ingeniería Mecatrónica', 1008);
select Carrera.Codigo, Carrera.Nombre, Carrera.Coordinador, Coordinador.Nombre, Instituto.Nombre from Carrera
inner join Coordinador on Carrera.Coordinador = Coordinador.NoEmp
inner join Instituto on Coordinador.Instituto = Instituto.Clave;