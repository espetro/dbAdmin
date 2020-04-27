-- EXAMEN PARCIAL 1 2020 ABD
-- 20-APR-20 11.07.18.225045000 AM EUROPE/PARIS
-- Joaquin Terrasa Moya

-- Mi usuario: FSE1T2N6
-- Cambiar todas las palabras 'FSEXXX' por 'FSE1T2N6'

-- Instrucciones ya ejecutadas
CREATE ROLE R_EXAMEN2020;
CREATE ROLE R_CORRIGE;
CREATE USER FSExxx identified by password;
GRANT R_EXAMEN2020, CONNECT, CREATE TABLE, CREATE VIEW TO
FSExxx;
GRANT SELECT, UPDATE (RESPUESTA) ON FIS2020.V_PREGUNTAS TO
R_EXAMEN2020;

-- [1]
-- Comprobamos si ya existen los tablespaces
SELECT * FROM DBA_TABLESPACES WHERE USER='FSE1T2N6';
-- Si existen! Entonces vamos a crear las tablas

CREATE TABLE MARCA (
    IDMARCA NUMBER,
    NOMBRE VARCHAR2(50),
    PRECIOHORA NUMBER(6,2) )
    TABLESPACE TS_EXAMEN2020
    PCTFREE 10;
-- NUMBER(6,2): precision 6, scale 2

INSERT INTO MARCA VALUES (1, 'TOYOTA', 10.1);
COMMIT;

-- [2]
CREATE TABLE MODELO (
    IDMODELO NUMBER,
    MARCA_IDMARCA NUMBER,
    NOMBRE VARCHAR2(100),
    NUMPUERTAS NUMBER,
    COMBUSTIBLE VARCHAR2(64),
    CAPACMALETERO NUMBER)
    TABLESPACE TS_ALUMNOS
    PCTFREE 15;
    
INSERT INTO MARCA VALUES (1, 'TOYOTA', 10.1);
COMMIT;

-- [3]
ALTER TABLE MARCA ADD CONSTRAINT PK_MARCA PRIMARY KEY (IDMARCA);
ALTER TABLE MODELO ADD CONSTRAINT PK_MODELO PRIMARY KEY (IDMODELO);
ALTER TABLE MODELO
    ADD CONSTRAINT FK_MODELO_MARCA
    FOREIGN KEY (MARCA_IDMARCA)
    REFERENCES MARCA(IDMARCA);

-- Podemos comprobar su correcta creacion con la siguiente consulta
SELECT * FROM user_constraints;

-- Ademas, hemos de comprobar las cuotas disponibles en los tablespaces disponibles
SELECT * FROM USER_TS_QUOTAS;
select TABLESPACE_NAME from SYS.DBA_TABLES WHERE OWNER='FSE1T2N6'
select TABLESPACE_NAME from SYS.DBA_INDEXES WHERE OWNER='FSE1T2N6';
-- Los indices (claves primarias y foraneas!) se han creado en TS_OMEGA
-- por defecto, se han creado correctamente
-- mientras que las tablas estan en TS_ALUMNOS y TS_EXAMEN2020

-- [4]
CREATE INDEX IDX_MOD_COMB ON MODELO(COMBUSTIBLE)
    TABLESPACE TS_ALUMNOS;
CREATE UNIQUE INDEX IDX_MAR_NOM ON MARCA(NOMBRE)
    TABLESPACE TS_ALUMNOS;
CREATE BITMAP INDEX IDX_MOD_MAR ON MODELO(MARCA_IDMARCA)
    TABLESPACE TS_ALUMNOS;
-- si el num. de marcas es pequeño, este indice es muy eficiente.
CREATE INDEX IDX_MOD_NOM ON MODELO(UPPER(NOMBRE))
    TABLESPACE TS_ALUMNOS;

-- [5]
GRANT SELECT, UPDATE (CAPACMALETERO) ON MODELO TO R_CORRIGE;
-- para autorizar la lectura de algunas columnas, es recomendable usar una vista
CREATE VIEW V_CORRIGE_MARCA AS
    SELECT IDMARCA, NOMBRE FROM MARCA;
GRANT SELECT ON V_CORRIGE_MARCA TO R_CORRIGE;

-- [6]
SELECT * FROM fis2020.v_preguntas;

-- [6.1] obtén el tipo del índice IDX_PUERTAS creado para una tabla del usuario AUTORACLE
SELECT INDEX_TYPE FROM dba_indexes
    WHERE TABLE_OWNER=''AUTORACLE''
    AND INDEX_NAME=''IDX_PUERTAS'';
-- Aun asi, no es el usuario AUTORACLE el que tiene esa tabla, sino ESC!
UPDATE fis2020.v_preguntas
SET respuesta='BITMAP'
WHERE id = 1;

-- [6.2] Obtén el nombre de tu tablespace por defecto (el del usuario creado para este examen)
SELECT DEFAULT_TABLESPACE FROM USER_USERS;

UPDATE fis2020.v_preguntas
SET respuesta='TS_OMEGA'
WHERE id = 2;

-- [6.3] Indica el nombre (ruta completa) del fichero de datos más pequeño en la base de datos
SELECT FILE_NAME, BYTES FROM dba_data_files ORDER BY BYTES DESC;

UPDATE fis2020.v_preguntas
SET respuesta='/u01/app/oracle/oradata/APOLO/sysaux01.dbf'
WHERE id = 3;

-- [6.4] Indica el nombre del usuario con más triggers en la base de datos
SELECT OWNER, COUNT(*) as TOTAL
    FROM dba_triggers
    GROUP BY OWNER
    ORDER BY TOTAL DESC;

UPDATE fis2020.v_preguntas
SET respuesta='MDSYS'
WHERE id = 4;

-- [6.5] Obtén cuantos minutos puede estar un usuario sin hacer nada antes de que se le cierre la sesión
-- para el perfil P_ALUMNO
SELECT LIMIT FROM DBA_PROFILES WHERE PROFILE='P_ALUMNO' AND RESOURCE_NAME='IDLE_TIME';

UPDATE fis2020.v_preguntas
SET respuesta='60'
WHERE id = 5;