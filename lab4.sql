-- Practica 1 Nivel Fisico - Instancia
-- Joaquin Terrasa, a 24 de Marzo de 2020

-- NOTA: Las sentencias 'PRINT' por si solas no son instrucciones SQL, sino documentacion para los labs. Esto lo hago porque el linter de SQL lo colorea.
-- Si se desea ejecutar PRINT('<texto>'), entonces usar el comando SELECT '<texto>' FROM DUAL;

-- SQLPLUS+
-- https://docs.oracle.com/cd/B14117_01/server.101/b12170/qstart.htm

-- Usando la BD en local (Oracle XE 11.0)

-- [1] Conectar como sys as sysdba desde sqlplus
-- CONNECT / as sysdba
-- password: dba
CONNECT /dba@localhost:1521/xe as sysdba

-- [2] Cerrar la instancia con "Shutdown immediate"
SHUTDOWN IMMEDIATE
-- Database closed.
-- Database dismounted.
-- ORACLE instance shut down.

-- [3] Intentar acceder desde otro sqlplus o sqldeveloper
CONNECT /dba@localhost:1521/xe as sysdba
-- ERROR:
-- ORA-12514: TNS:listener does not currently know of service requested in connect
-- descriptor

-- [4] Crear la instancia sin montarla
CONNECT / as sysdba
-- Connected to an idle instance
STARTUP NOMOUNT
-- ORACLE instance started.

-- Total System Global Area 1068937216 bytes
-- Fixed Size                  2260048 bytes
-- Variable Size             746587056 bytes
-- Database Buffers          314572800 bytes
-- Redo Buffers                5517312 bytes

-- [5] Intentar acceder desde sqlplus o sqldeveloper
CONNECT usuario1/usuario
-- ERROR:
-- ORA-01033: ORACLE initialization or shutdown in progress
-- Process ID: 0
-- Session ID: 0 Serial number: 0

-- [6] Montarla ('db_name string XE')
ALTER DATABASE MOUNT;
-- Database altered.

-- [7] Intentar acceder desde sqlplus
SQLPLUS usuario1/usuario
-- ERROR:
-- ORA-01033: ORACLE initialization or shutdown in progress
-- Process ID: 0
-- Session ID: 0 Serial number: 0

-- [8] Abrir la base de datos
ALTER DATABASE OPEN;
-- Database altered.

-- [9] Intentar acceder desde sqlplus
SQLPLUS usuario1/usuario
-- Connected to:
-- Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

-- [10] Crear fichero de inicio 
-- http://www.dba-oracle.com/concepts/pfile_spfile.htm
CREATE pfile='C:\Users\Pachacho\Documents\CodeProjects\ABD_2020\my_pfile.ora' FROM SPFILE;
CREATE pfile='C:\Users\Pachacho\Documents\CodeProjects\ABD_2020\backup.ora' FROM SPFILE;


-- [11] Editarlo
-- -- C:\Users\alumnos\Oracle_instalacion\database\initORCL.ora
-- -- Borrar las 3 líneas donde se indican los tamaños de las zonas de memoria y modificar las siguientes:
-- -- -- *.memory_target=450m
-- -- -- *.open_cursors=100
-- -- -- *.processes=100

-- [12] Arrancar con el PFILE
-- -- Startup pfile ='C:\Users\alumnos\Oracle_instalacion\database\initORCL.ora'
SHUTDOWN IMMEDIATE;
STARTUP pfile='C:\Users\Pachacho\Documents\CodeProjects\ABD_2020\my_pfile.ora';

-- [13] Crear un SPFILE nuevo
-- -- Create spfile from pfile
CREATE spfile FROM pfile='C:\Users\Pachacho\Documents\CodeProjects\ABD_2020\my_pfile.ora';

-- [14] Parar y arrancar
-- [15] Comprobar de nuevo el tamaño de la SGA
SHUTDOWN IMMEDIATE;
STARTUP;
-- SQL> SHUTDOWN IMMEDIATE;
-- Database closed.
-- Database dismounted.
-- ORACLE instance shut down.
-- SQL> STARTUP;
-- ORACLE instance started.

-- Total System Global Area  471830528 bytes
-- Fixed Size                  2254304 bytes
-- Variable Size             297798176 bytes
-- Database Buffers          167772160 bytes
-- Redo Buffers                4005888 bytes
-- Database mounted.
-- Database opened.
