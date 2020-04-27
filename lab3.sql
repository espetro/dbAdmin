-- LAB 1: 17 Marzo 2020
-- Joaquin Terrasa Moya

-- NOTA: Las sentencias 'PRINT' por si solas no son instrucciones SQL, sino documentacion para los labs. Esto lo hago porque el linter de SQL lo colorea.
-- Si se desea ejecutar PRINT('<texto>'), entonces usar el comando SELECT '<texto>' FROM DUAL;

-- [1] Conectate a la base de datos como system.
-- Passwd system: dba
sqlplus system/dba as sysdba

-- [2] Ejecuta todos los pasos necesarios para crear un wallet de tipo FILE tal y como hemos visto en clase para permitir implementar TDE (Transparent Data Encryption) sobre columnas de las tablas que seleccionemos.
-- https://docs.oracle.com/cd/E11159_01/books/install/eBilling_Install_DatabaseOra8.html
-- En general, podemos usar 'C:\wallet'
ALTER SYSTEM SET "WALLET_ROOT"='C:\wallet' scope=SPFILE;

-- Comprobar con
-- SELECT * FROM V$PARAMETER WHERE NAME LIKE 'wallet%'

-- Reiniciamos la instancia:
-- https://docs.oracle.com/database/121/ADMQS/GUID-06A0DC57-50BC-453F-8E81-FF2DEDF93467.htm#ADMQS0521
SHUTDOWN IMMEDIATE;
STARTUP;

ALTER SYSTEM SET "TDE_CONFIGURATION"='KEYSTORE_CONFIGURATION=FILE' scope=both;

-- Nos conectamos como sys Key Manager
-- { desde syskm }
sqlplus / as syskm

-- Creamos un password-protected software keystore
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY adminbd2020;

-- Le convertimos en auto-login
ADMINISTER KEY MANAGEMENT CREATE AUTO_LOGIN KEYSTORE FROM KEYSTORE IDENTIFIED BY adminbd2020;

ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY adminbd2020 WITH BACKUP;
-- keystore not open!
ADMINISTER KEY MANAGEMENT SET KEYSTORE open IDENTIFIED BY adminbd2020;
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY adminbd2020 WITH BACKUP
-- keystore altered.

-- [3] Todo el trabajo de tu proyecto debería estar en un espacio de tablas aparte. En el peor de los casos puede estar en el tablespace USERS. Asumiremos en adelante que usamos el esquema en el que estás desarrollando tu proyecto (si no lo es, no pasa nada, utiliza tu propio nombre). Más adelante, se volcará lo aquí aprendido al esquema final de AUTORACLE.
PRINT('Sin problema! Tenemos TS_AUTORACLE de la sesion de lab anterior')

-- [4] Usar una o varias tablas susceptible de precisar que sus datos estén cifrados (ver enunciado del trabajo en grupo). Si no tuvieras nada creado en el momento de la realización de esta práctica, puedes crearte un par de tablas donde una de ellas fueran, por ejemplo, los empleados. Y, por supuesto, introducir algunos datos de ejemplo.
PRINT('Crearemos dos tablas del modelo ER ganador que no esten relacionadas: Empleado y Proveedor')

PRINT('Creamos un user "PRACTICAS" para controlar los datos de nuestro modelo')

-- { desde sysdba }
CREATE USER PRACTICAS IDENTIFIED BY practicas
    DEFAULT TABLESPACE TS_AUTORACLE
    QUOTA 5M ON TS_AUTORACLE
    PROFILE PERF_ADMINISTRATIVO;

-- [5] Parece obvio que en la tabla empleados habrá una serie de columnas que almacenan información sensible. Identifícalas y haz que estén siempre cifradas en disco. ASEGURATE QUE HAYA AL MENOS UNA COLUMNA DE TEXTO NO CIFRADA Y OTRA CIFRADA con objeto de poder hacer comprobaciones en los siguientes pasos
PRINT('Se crea una tabla "Empleado" para encriptar algunos datos, y agregamos datos a la tabla')

CREATE TABLE practicas.Empleado (
	dni VARCHAR(9) ENCRYPT,
	nombre VARCHAR(128),
	apellido1 VARCHAR(64),
	apellido2 VARCHAR(64),
	despedido VARCHAR(2) DEFAULT 'NO',
	sueldo NUMBER(6) ENCRYPT,
	horasTrabajadas NUMBER(10),
	puesto VARCHAR(128),
	retenciones NUMBER(10) )
    TABLESPACE TS_AUTORACLE;

desc PRACTICAS.EMPLEADO;

-- Agregamos datos
-- { desde practicas }
INSERT ALL
	INTO Empleado (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones)
	VALUES ('12345678A', 'Pedro', 'Fernandez', 'Rico', 'NO', 100, 0, 'Becario', 0.1)

	INTO Empleado (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones)
	VALUES ('12345678B', 'Enrique', 'Fernandez', 'Rico', 'NO', 100, 0, 'Becario', 0.1)

	INTO Empleado (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones)
	VALUES ('12345678C', 'Juan', 'Fernandez', 'Rico', 'SI', 10000, 0, 'Presidente', 0.01)

	INTO Empleado (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones)
	VALUES ('12345678D', 'Pablo', 'Fernandez', 'Rico', 'NO', 100, 0, 'Becario', 0.1)
SELECT 1 FROM DUAL;

-------------
PRINT('Se crea una tabla "Proveedor" para encriptar algunos datos, y agregamos datos a la tabla')

-- { desde sysdba }
CREATE TABLE PRACTICAS.PROVEEDOR (
	nif VARCHAR(10) ENCRYPT,
	telefono VARCHAR(15),
	nombre VARCHAR(128),
	email VARCHAR(128) ENCRYPT,
	direccion VARCHAR(128),
	codigoPostal VARCHAR(64),
	paginaWeb VARCHAR(128)
	) TABLESPACE TS_AUTORACLE;

-- { desde practicas }
INSERT ALL
	INTO Proveedor (nif, telefono, nombre, email, direccion, codigoPostal, paginaWeb)
	VALUES ('K1234567Z', '+34677132312', 'UMA', 'info@uma.es', 'Calle Larios 12', '29000', 'http://uma.es')

	INTO Proveedor (nif, telefono, nombre, email, direccion, codigoPostal, paginaWeb)
	VALUES ('K1234567E', '+34677152312', 'UCO', 'info@uco.es', 'Calle Biznaga 12', '29000', 'http://uco.es')

	INTO Proveedor (nif, telefono, nombre, email, direccion, codigoPostal, paginaWeb)
	VALUES ('K1234567W', '+34674132312', 'UPF', 'info@upf.es', 'Carrer Bonanova 12', '29000', 'http://upf.es')
SELECT 1 FROM DUAL;

-- [6] Una vez lo hayas hecho, comprueba que los cambios son efectivos mediante la consulta de la vista del diccionario de datos adecuada
SELECT * FROM V$ENCRYPTION_WALLET;

-- { desde 'practicas' }
SELECT * FROM USER_TAB_COLUMNS;
SELECT COUNT(*) FROM PROVEEDOR;
SELECT COUNT(*) FROM EMPLEADO;

SELECT * FROM USER_ENCRYPTED_COLUMNS;
PRINT('ENCRYPTION_ALG: AES 192 bits key')

-- [7] Prueba a insertar varias filas en la tabla de empleados (y en todas aquellas tablas que sea necesario). A continuación, puedes forzar a Oracle a que haga un flush de todos los buffers a disco mediante la instrucción 'alter system flush buffer_cache;'
PRINT('Ya se realiza arriba');

-- { desde 'sys as sysdba' }
ALTER SYSTEM FLUSH BUFFER_CACHE;

-- Comprueba a continuación el contenido del fichero que contiene el tablespace con estos datos. Ese fichero lo podremos encontrar en el directorio en el que hayamos creado el tablespace en el que se encuentra la tabla que estamos utilizando.
PRINT('TS_AUTORACLE lo asociamos al fichero AUTORACLE.dbf')

-- { desde 'sys as sysdba' }
SELECT FILE_NAME from dba_data_files;
PRINT('Obtenemos "C:\Users\Alumnos\Oracle_Instalacion\Database\Autoracle.DBF"')

-- ¿Se pueden apreciar en el fichero los datos escritos? ¿Por qué?
PRINT('Ejecutamos "strings.exe C:\Users\alumnos\Oracle_instalacion\database\AUTORACLE.DBF" y obtenemos algunos strings introducidos, como "TS_AUTORACLE", "Pablo Fernandez Rico", o "Carrer Bonanova 12"')

PRINT('En concreto, estos son datos que no configuramos como "ENCRYPT"')

-- [8] Vamos ahora a aplicar políticas de autorización más concretas mediante VPD. Supongamos que deseamos controlar el acceso a los datos de los empleados. Cuando un usuario con permiso de lectura sobre la tabla empleado acceda, sólo tendrá disponibles sus datos (excepto si se trata de un usuario que haya accedido como SYSDBA (privilegio de administración)).

CREATE OR REPLACE FUNCTION PRACTICAS.sec_function(
	p_schema VARCHAR2, p_obj VARCHAR2
	) RETURN VARCHAR2
IS
  user VARCHAR2(100);
BEGIN
	if ( SYS_CONTEXT('USERENV', 'ISDBA')='TRUE' )
	then return ''; -- Si el usuario se conecta como sysdba, podrá ver toda la tabla.
	else
		user := SYS_CONTEXT('userenv', 'SESSION_USER');
		return 'UPPER(USER_NAME) = ''' || user || '''';
	end if;
END;

PRINT('Donde')
PRINT('"USERENV" es el contexto de la aplicacion')
PRINT('P_SCHEMA es el schema en el que se encuentra dicha tabla o vista')
PRINT('P_OBJ es el nombre de la tabla o vista al cual se le aplicará la política')

-- { desde PRACTICAS }
SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE = 'FUNCTION';

-- [9] Debemos añadir una columna (user_name) a la tabla de empleados en la que almacenamos el username de conexión

-- { desde PRACTICAS }
ALTER TABLE Empleado
ADD USER_NAME VARCHAR(64);

-- [10] Crearemos un usuario (cuyo nombre debe estar previamente presente en el campo user_name de alguna fila) de forma que podamos probar la política. Comprobaremos, que ese usuario, al conectarse, puede ver todos los datos de la tabla empleados.

PRINT('Aprovechamos los 2 usuarios creados en el lab anterior')

UPDATE Empleado
SET USER_NAME = 'USUARIO2'
WHERE PUESTO = 'Becario';

UPDATE Empleado
SET USER_NAME = 'USUARIO1'
WHERE PUESTO = 'Presidente';

PRINT('Nos aseguramos de que ambos usuarios puedan conectarse y ver las tablas')

-- { desde sys as sysdba }
GRANT CREATE SESSION TO USUARIO1, USUARIO2;
GRANT SELECT ON PRACTICAS.Empleado TO USUARIO1, USUARIO2;
GRANT SELECT ON PRACTICAS.Proveedor TO USUARIO1, USUARIO2;

-- { desde USUARIO1 }
SELECT * FROM PRACTICAS.Empleado; -- Funciona!

-- [10.1] Añadiremos la política a la tabla empleados (desde un usuario con el role de DBA).  Y después comprobaremos que ocurre después de añadir la política. Una aclaración, al añadir una política, ésta se encuentra activa por defecto.

-- { desde sysdba }
BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'PRACTICAS',
        object_name => 'EMPLEADO',
        policy_name => 'POL_USUARIO_EMPLEADO',
        function_schema => 'PRACTICAS',
        policy_function => 'SEC_FUNCTION',
        STATEMENT_TYPES => 'SELECT, UPDATE, DELETE'
    );
END;

SELECT * FROM ALL_POLICIES;

SELECT * FROM PRACTICAS.Empleado;
PRINT('Al parecer, los datos de la tabla...se han borrado! Lo unico que he hecho es suspender la VM tras agregar la "policy", y reabrirla despues')

GRANT INSERT, UPDATE ON PRACTICAS.EMPLEADO TO USUARIO1;
GRANT INSERT, UPDATE ON PRACTICAS.EMPLEADO TO USUARIO2;

-- { desde USUARIO1 }
INSERT INTO PRACTICAS.EMPLEADO (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones, user_name)
	VALUES ('12345678A', 'Pedro', 'Fernandez', 'Rico', 'NO', 100, 0, 'Becario', 0.1, 'USUARIO1');
INSERT INTO PRACTICAS.EMPLEADO (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones, user_name)
	VALUES ('12345678C', 'Jose', 'Fernandez', 'Rico', 'NO', 100, 0, 'Becario', 0.1, 'USUARIO1');

SELECT * FROM PRACTICAS.EMPLEADO;

PRINT('Ahora si! Solo se ven las filas insertadas donde "USER_NAME"="USUARIO1"')

-- { desde USUARIO2 }
INSERT INTO PRACTICAS.EMPLEADO (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones, user_name)
	VALUES ('12345678T', 'Pedro', 'Gonzalez', 'Rico', 'NO', 100, 0, 'Becario', 0.1, 'USUARIO2');
INSERT INTO PRACTICAS.EMPLEADO (dni, nombre, apellido1, apellido2, despedido, sueldo, horasTrabajadas, puesto, retenciones, user_name)
	VALUES ('12345678R', 'Pedro', 'Fernandez', 'Perez', 'NO', 100, 0, 'Presidente', 0.1, 'USUARIO2');

SELECT * FROM PRACTICAS.EMPLEADO;

PRINT('Ahora si! Solo se ven las filas insertadas donde "USER_NAME"="USUARIO1"')

-- { desde PRACTICAS }
SELECT * FROM PRACTICAS.EMPLEADO;

PRINT('Vaya! PRACTICAS no puede ver ninguna de las filas insertadas anteriormente')

-- { desde SYSTEM }
SELECT * FROM PRACTICAS.EMPLEADO;

PRINT('Vaya! SYSTEM no puede ver ninguna de las filas insertadas anteriormente. Solo se puede ver con el rol de sysdba')

-- { desde SYSDBA }
SELECT COUNT(*) FROM PRACTICAS.Empleado;

PRINT('Correcto. Si podemos')

-- [11] Proporcionemos los permisos necesarios a ese nuevo usuario que acabamos de crear para las pruebas para que, por lo menos, pueda consultar y actualizar datos en la tabla.
PRINT('Ya se ha hecho anteriormente')

-- [12] ¿Qué ocurre cuando nos conectamos desde un usuario existente en la tabla empleados y realizamos un select de todo?
PRINT('Ya se ha hecho anteriormente')

-- [13] ¿Y si realizamos un update?

-- { desde USUARIO1 }
UPDATE PRACTICAS.EMPLEADO
SET APELLIDO2 = 'Bosch'
WHERE USER_NAME = 'USUARIO2';

PRINT('No se actualiza ninguna fila')

-- [14] ¿Podemos hacer update de cualquier columna? ¿Tiene sentido que se pueda? Prueba a hacer un update de la columna user_name. ¿Qué ocurre? ¿Es el comportamiento esperado por parte del usuario?
UPDATE PRACTICAS.EMPLEADO
SET APELLIDO2 = 'Bosch'
WHERE PUESTO = 'Presidente';

PRINT('Puedo modificar las filas visibles al usuario desde el que realizo el UPDATE')

UPDATE PRACTICAS.EMPLEADO
SET USER_NAME = 'PRACTICAS'
WHERE PUESTO = 'Presidente';

PRINT('Se puede! Ahora esa fila es la unica que puede ver el usuario "PRACTICAS". Creo que no es el comportamiento esperado')

-- [15] En caso negativo, ¿Como podemos evitarlo? (tip: revisa la documentación de dbms_rls.add_policy que utilizaste antes para añadirla para ver si hay una opción que nos permita hacer lo que queremos, si es que creemos que debemos hacer algo).

PRINT('Es la opcion relativa a "STATEMENT_TYPES". Podemos decir que solo sea "SELECT" o "INSERT"')
PRINT('https://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_rls.htm#BABFIFJG')
PRINT('Eliminamos la "Policy" y la volvemos a crear')

-- { desde sysdba }
BEGIN
    DBMS_RLS.DROP_POLICY (
        object_schema => 'PRACTICAS',
        object_name => 'EMPLEADO',
        policy_name => 'POL_USUARIO_EMPLEADO'
    );
END;

BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'PRACTICAS',
        object_name => 'EMPLEADO',
        policy_name => 'POL_USUARIO_EMPLEADO',
        function_schema => 'PRACTICAS',
        policy_function => 'SEC_FUNCTION',
        STATEMENT_TYPES => 'SELECT, UPDATE, DELETE',
		update_check => TRUE
    );
END;

-- { desde PRACTICAS }
UPDATE PRACTICAS.EMPLEADO
SET USER_NAME = 'USUARIO1'
WHERE DNI = '12345678T';

PRINT('No lo permite! La opcion "UPDATE_CHECK". Devuelve')
PRINT('ORA-28115: la política viola la opción de comprobación')

-- [16] También podemos aplicar políticas sobre columnas, en lugar de sobre vistas o tablas enteras. Continuando con nuestro ejemplo de los empleados, imaginemos que queremos permitir a los usuarios consultar todos los datos de la tabla excepto cuando también se solicita una columna determinada (ej. salario), en cuyo caso queremos que se muestren sólo los datos del usuario.

-- { desde sysdba }
CREATE OR REPLACE FUNCTION PRACTICAS.sec_function_salary(
	p_schema VARCHAR2, p_obj VARCHAR2) RETURN VARCHAR2
IS
  user VARCHAR2(100);
BEGIN
  user := SYS_CONTEXT('userenv', 'SESSION_USER');
  return 'UPPER(USER_NAME) = ''' || user || '''';
END;

PRINT('Aplicamos esta funcion de manera similar a "sec_function"')

-- [17] Investiga en la documentación la función que utilizamos para añadir una política nueva (dbms_rls.add_policy). ¿Qué cambios deberíamos hacer para lograr nuestro objetivo? Tip: Desactiva previamente la política anterior para no tener conflictos en los resultados.

BEGIN
    DBMS_RLS.ENABLE_POLICY (
        object_schema => 'PRACTICAS',
        object_name => 'EMPLEADO',
        policy_name => 'POL_USUARIO_EMPLEADO',
		enable => FALSE
    );
END;

BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'PRACTICAS',
        object_name => 'EMPLEADO',
        policy_name => 'POL_USUARIO_EMPLEADO_SUELDO',
        function_schema => 'PRACTICAS',
        policy_function => 'sec_function_salary',
        STATEMENT_TYPES => 'SELECT, UPDATE, DELETE',
		sec_relevant_cols => 'SUELDO'
    );
END;

-- { desde USUARIO1 }
SELECT * FROM PRACTICAS.Empleado;
PRINT('Devuelve toda la tabla')

SELECT SUELDO FROM PRACTICAS.Empleado;
PRINT('Devuelve solo las filas relativas al usuario')

-- [18] Qué desventajas pueden llegar a tener este tipo de control de acceso más específico? Si no encuentras la respuesta discútelo con el profesor.

PRINT('El trade-off de mayor seguridad supone que los usuarios que vayan a perder la "usabilidad" a la hora de introducir datos en la BD, pues tienen que ser mas precisos. Las operaciones de los usuarios, en general, tienden a generar mas errores si no estan debidamente informados.')