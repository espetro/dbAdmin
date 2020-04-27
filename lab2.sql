-- LAB 1: 10 Marzo 2020
-- Joaquin Terrasa Moya
-- Respecto a Oracle 18.0 Multitenant: 'SELECT * FROM V$containers' (seleccionar pdb3!!)

-- [3] 
SELECT * FROM DBA_TABLESPACES; -- no hay ningun ts 'TS_AUTORACLE'

CREATE TABLESPACE TS_AUTORACLE
    DATAFILE 'AUTORACLE.dbf'
    SIZE 10M
    AUTOEXTEND ON;

SELECT TABLESPACE_NAME, CON_ID FROM CDB_TABLESPACES;
-- Oracle 18.0 Multitenant Si se creó en pdb1, borrar (es el pdb 'root')

-- [4] En Oracle 18.0 Multitenant, hay que poner 'C##' antes del nombre del perfil/rol/usuario
CREATE PROFILE PERF_ADMINISTRATIVO LIMIT
    IDLE_TIME 5
    FAILED_LOGIN_ATTEMPTS 3;

-- [5]
CREATE PROFILE PERF_EMPLEADO LIMIT
    SESSIONS_PER_USER 4
    PASSWORD_LIFE_TIME 30;

-- [6]
ALTER SYSTEM SET RESOURCE_LIMIT=true;

-- [7]
CREATE ROLE C##R_ADMINISTRADOR_SUPER;
GRANT CREATE SESSION, CREATE TABLE TO C##R_ADMINISTRADOR_SUPER;

-- [8]
CREATE USER USUARIO1 IDENTIFIED BY usuario
    DEFAULT TABLESPACE TS_AUTORACLE
    QUOTA 1M ON TS_AUTORACLE
    PROFILE PERF_ADMINISTRATIVO;
GRANT R_ADMINISTRADOR_SUPER TO USUARIO1;

CREATE USER USUARIO2 IDENTIFIED BY usuario
    DEFAULT TABLESPACE TS_AUTORACLE
    QUOTA 1M ON TS_AUTORACLE
    PROFILE PERF_ADMINISTRATIVO;
GRANT R_ADMINISTRADOR_SUPER TO USUARIO2;

-- [9]
-- SELECT * FROM ALL_OBJECTS WHERE OWNER = 'USUARIO1'
CREATE TABLE USUARIO1.TABLA2 (CODIGO NUMBER);
CREATE TABLE USUARIO2.TABLA2 (CODIGO NUMBER);

-- [10] (creado desde system - por eso se indica 'USUARIO1')
CREATE OR REPLACE PROCEDURE USUARIO1.PR_INSERTA_TABLA2 (
        P_CODIGO IN NUMBER
    ) AS
BEGIN
    INSERT INTO TABLA2 VALUES (P_CODIGO);
END PR_INSERTA_TABLA2;

-- [11] (connects as USUARIO1/usuario - SQLPLUS+) (si! funciona)
EXEC PR_INSERTA_TABLA2(45);

-- [12] (as USUARIO1/usuario)
GRANT EXECUTE ON PR_INSERTA_TABLA2 TO USUARIO2;

-- [13] (si! funciona)
EXEC USUARIO1.PR_INSERTA_TABLA2(46);

-- [14]
-- el dato se inserta en la tabla del USUARIO1, pues el procedimiento usa esta tabla!
-- USUARIO2 solo tendrá los permisos que se usen dentro del procedimiento mientras usa
-- el procedimiento

-- [15]
CREATE OR REPLACE PROCEDURE USUARIO1.PR_INSERTA_TABLA2 (
        P_CODIGO IN NUMBER
    ) AS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO TABLA2 VALUES ('||P_CODIGO||')';
END PR_INSERTA_TABLA2;

-- [16] Si! Funciona
-- [17] Si! Funciona - USUARIO2 lo ejecuta como si fuese USUARIO1FF

-- [18] desde system
-- SELECT * FROM ALL_OBJECTS WHERE OWNER = 'USUARIO1'
CREATE OR REPLACE PROCEDURE USUARIO1.PR_CREA_TABLA (P_TABLA IN VARCHAR2, P_ATRIBUTO IN VARCHAR2) AS
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE '||P_TABLA||'('||P_ATRIBUTO||' NUMBER(9))';
END PR_CREA_TABLA;

-- [19]
-- esto ocurre porque 'EXECUTE IMMEDIATE' requiere que los usuarios tengan los permisos asignados
-- de manera explicita y no a traves de roles. Esto es porque las instrucciones DDL son mas peligrosas para
-- la gestion de la BD.

-- [20] (desde System)
GRANT CREATE TABLE TO USUARIO1;
GRANT EXECUTE ON USUARIO1.PR_CREA_TABLA TO USUARIO2;

-- [21] (desde USUARIO2) Funciona!
EXEC USUARIO1.PR_CREA_TABLA('CONTACTOS', 'TLFO');

-- [22]
-- Por defecto, los usuarios que se crean desde OracleDB no tienen acceso para conectarse.
-- Por ello, es habitual que los usuarios tengan que especificar su contraseña antes de iniciar sesion
-- en la BD.
-- Por otro lado, OracleDB tambien crea usuarios para administrar la BD.

-- [23]
SELECT RESOURCE_NAME FROM DBA_PROFILES WHERE PROFILE = 'DEFAULT';
-- COMPOSITE_LIMIT
-- SESSIONS_PER_USER
-- CPU_PER_SESSION
-- CPU_PER_CALL
-- LOGICAL_READS_PER_SESSION
-- LOGICAL_READS_PER_CALL
-- IDLE_TIME
-- CONNECT_TIME
-- PRIVATE_SGA
-- FAILED_LOGIN_ATTEMPTS
-- PASSWORD_LIFE_TIME
-- PASSWORD_REUSE_TIME
-- PASSWORD_REUSE_MAX
-- PASSWORD_VERIFY_FUNCTION
-- PASSWORD_LOCK_TIME
-- PASSWORD_GRACE_TIME

ALTER PROFILE DEFAULT LIMIT
    FAILED_LOGIN_ATTEMPTS 4
    PASSWORD_GRACE_TIME 5;
    
-- (como USUARIO1)
-- ERROR:
-- ORA-28000: the account is locked
ALTER USER USUARIO1 ACCOUNT UNLOCK;

-- 'SEC_MAX_FAILED_LOGIN_ATTEMPTS' specifies the number of auth attempts that can be made BY A CLIENT.

-- Los parametros dinamicos cambian durante el 'runtime'.