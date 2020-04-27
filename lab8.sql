-- Practica 8 ABD
-- Joaquin Terrasa Moya, a 22 Abril 2020

-- (RELACION INDIVIDUAL PL/SQL)
-- [1] Cree una tabla llamada DATOS
CREATE TABLE DATOS (
    CODIGO NUMBER(9),
    NOMBRE VARCHAR2(15),
    FECHA DATE)
    TABLESPACE TS_ALUMNOS
    PCTFREE 10;

-- [2] Cree una secuencia llamada SECUENCIA_DATOS que comienza en el valor 100 y se incrementa de 3 en 3.
CREATE SEQUENCE SECUENCIA_DATOS START WITH 100 INCREMENT BY 3;

-- [3] Cree una función NUM_ALEATORIO que tiene un argumento N de tipo NUMBER y produce un número aleatorio con N dígitos. Utilizar el paquete DBMS_RANDOM.
CREATE OR REPLACE FUNCTION NUM_ALEATORIO(n IN NUMBER) RETURN NUMBER IS
BEGIN
    IF (n = 0) THEN
        RETURN -1;
    ELSIF (n = 1) THEN
        RETURN ROUND(DBMS_RANDOM.VALUE(0,9));
    ELSE
        RETURN ROUND(DBMS_RANDOM.VALUE(10 ** (n-1), (10 ** n) - 1));
    END IF;
END NUM_ALEATORIO;

SELECT NUM_ALEATORIO(3) FROM DUAL;

-- [4] Cree una función llamada CADENA_ALEATORIA con un argumento N de tipo NUMBER produce una cadena aleatoria de caracteres en mayúscula de longitud N.
CREATE OR REPLACE FUNCTION CADENA_ALEATORIA(n IN NUMBER) RETURN VARCHAR2 IS
BEGIN
    IF (n <= 0) THEN
        RETURN '';
    ELSE
        RETURN DBMS_RANDOM.STRING('U', n);
    END IF;
END;

SELECT CADENA_ALEATORIA(3) FROM DUAL;

-- [5] Cree una función llamada CALCULAR_FECHA que recibe una fecha F, un día de la semana D y un número N y produce la siguiente fecha que cae en D a partir de F incrementada en N días
CREATE OR REPLACE FUNCTION CALCULAR_FECHA
    (f IN DATE, d in NUMBER, n IN NUMBER) RETURN DATE AS
    final_date DATE;
BEGIN
    final_date := f + n;
    LOOP
        EXIT WHEN (MOD(TO_CHAR(final_date, 'J'), 7) + 1) = d; -- obtiene el dia de la semana
        final_date := final_date + 1;
    END LOOP;
    RETURN final_date;
END;

SELECT CALCULAR_FECHA(SYSDATE, 6, 1) FROM DUAL; -- buscamos el proximo sabado

-- [6] Cree un procedimiento llamado RELLENAR que recibe como parámetro un número menor que 100 e introduce en DATOS ese número de tuplas. El valor del CODIGO se calcula a partir del valor de la secuencia. El nombre se genera como una cadena aleatoria usando CADENA_ALEATORIA ya creada en un punto anterior de esta relación.
-- 
-- Para introducir la fecha use la función CALCULAR_FECHA del apartado anterior a partir de los datos de la fecha actual y para el número N use una llamada a NUM_ALEATORIO. Si el argumento es mayor que 100 se generan solamente 100 tuplas nuevas.
CREATE OR REPLACE PROCEDURE RELLENAR(n IN NUMBER) AS
    loop_count NUMBER := n;
    fecha_tupla DATE;
BEGIN
    IF n > 100 THEN
        loop_count := 100;
    END IF;
    LOOP
        EXIT WHEN loop_count = 0;
        loop_count := loop_count - 1;
        fecha_tupla := CALCULAR_FECHA(SYSDATE, 1, NUM_ALEATORIO(2));
        INSERT INTO DATOS
            VALUES (SECUENCIA_DATOS.nextval, CADENA_ALEATORIA(5), fecha_tupla);
    END LOOP;
END;

-- [7] Cree una tabla llamada TB_OBJETOS con los siguientes atributos: NOMBRE, CODIGO, FECHA_CREACION, FECHA_MODIFICACION, TIPO, ESQUEMA_ORIGINAL. Recorra la vista ALL_OBJECTS y rellene esta tabla con los datos que se aportan en la vista. Use un cursor y no un INSERT directo.
CREATE TABLE TB_OBJETOS (
    NOMBRE VARCHAR2(200),
    CODIGO NUMBER(30),
    FECHA_CREACION DATE,
    FECHA_MODIFICACION DATE,
    TIPO VARCHAR2(200),
    ESQUEMA_ORIGINAL VARCHAR2(200))
    TABLESPACE TS_ALUMNOS;

DECLARE
    CURSOR tabla IS SELECT * FROM ALL_OBJECTS;
BEGIN
    FOR fila IN tabla LOOP
        INSERT INTO TB_OBJETOS
            VALUES (fila.OBJECT_NAME, fila.OBJECT_ID, fila.CREATED,
                    fila.LAST_DDL_TIME, fila.OBJECT_TYPE, fila.OWNER);
    END LOOP;
END;
/

SELECT * FROM TB_OBJETOS;

-- [8] Cree una tabla TB_ESTILO con los siguientes atributos: TIPO_OBJETO, PREFIJO. En esta tabla se guardan unas normas de estilo de modo que a cada tipo de objeto le corresponde un prefijo en su identificador. Así por ejemplo guardamos la tupla ('PROCEDURE','PR_') para indicar que un nombre correcto de procedimiento es PR_HOLA_MUNDO.
CREATE TABLE TB_ESTILO (
    TIPO_OBJETO VARCHAR2(60),
    PREFIJO VARCHAR2(30))
    TABLESPACE TS_ALUMNOS;

INSERT INTO TB_ESTILO VALUES('PROCEDURE', 'PR_');
INSERT INTO TB_ESTILO VALUES('TABLE', 'TB_');
INSERT INTO TB_ESTILO VALUES('FUNCTION', 'FUN_');

-- [9] Extienda el esquema de la tabla TB_OBJETOS en dos atributos: ESTADO y NOMBRE_CORRECTO. Cree un procedimiento llamado PR_COMPROBAR(ESQUEMA IN VARCHAR2) que recorre la tabla TB_OBJETOS y comprueba si se cumplen las normas de estilo según la tabla TB_ESTILO. El parámetro que recibe es el identificador del esquema sobre el que queremos comprobar las normas.
ALTER TABLE TB_OBJETOS ADD (
    ESTADO VARCHAR2(100),
    NOMBRE_CORRECTO VARCHAR2(230)); -- longitud del nombre + prefijo

CREATE OR REPLACE PROCEDURE PR_COMPROBAR(esquema in VARCHAR2 DEFAULT NULL) AS
    CURSOR tabla IS SELECT * FROM TB_OBJETOS;
    nuevo_nombre VARCHAR2(230);
    v_prefijo VARCHAR2(30);
    v_estado VARCHAR2(100);
BEGIN
    FOR fila in tabla LOOP
        IF (esquema <> NULL AND UPPER(fila.ESQUEMA_ORIGINAL) <> UPPER(esquema)) THEN
            CONTINUE; -- ignora la fila si el esquema no coincide
        END IF;

        -- falta recortar 'nuevo_nombre' si excede, aunque la columna es ya bastante larga

        SELECT PREFIJO INTO v_prefijo
            FROM TB_ESTILO
            WHERE TIPO_OBJETO = fila.TIPO;
        IF (fila.NOMBRE LIKE v_prefijo||'%') THEN -- si empieza por el prefijo
            nuevo_nombre := fila.NOMBRE;
            v_estado := 'CORRECTO';
        ELSE
            nuevo_nombre := v_prefijo||fila.NOMBRE;
            v_estado := 'INCORRECTO';
        END IF;

        UPDATE TB_OBJETOS
            SET NOMBRE_CORRECTO = nuevo_nombre, ESTADO = v_estado
            WHERE CODIGO = fila.CODIGO;
    END LOOP;
END;

-- Si no se especifica, se comprueba en todos. Actualice el atributo ESTADO de la tabla TB_OBJETOS con los valores CORRECTO o INCORRECTO según las normas de estilo y el atributo NOMBRE_CORRECTO con el identificador con el prefijo adecuado. El nuevo identificador se calcula anteponiendo el prefijo correcto al identificador antiguo.
-- Si el identificador nuevo excede el tamaño del OBJECT_NAME de Oracle, entonces pode el nuevo identificador por la derecha. Use un cursor de actualización para realizar este procedimiento.
'FALTA ESTO ULTIMO'

-- [10] Cree una tabla llamada TB_ERRORES con los atributos FECHA, RUTINA, CODIGO y MENSAJE. Cree varios procedimientos que producen errores de Oracle y guarda en la tabla TB_ERRORES un rastro de dichos errores. Así por ejemplo podemos crear el procedimiento:

CREATE TABLE TB_ERRORES (
    FECHA DATE,
    RUTINA VARCHAR2(200),
    CODIGO NUMBER(10),
    MENSAJE VARCHAR2(200))
    TABLESPACE TS_ALUMNOS;

-- Introduzca en estos procedimientos una sección de excepciones para introducir en TB_ERRORES la aparición de este error:
'ORA-01422: la recuperación exacta devuelve un número mayor de filas que el solicitado'

CREATE OR REPLACE PROCEDURE PR_SELECT_MAS_UNA_FILA AS
    VAR_FILA ALL_TABLES%ROWTYPE;
    msg VARCHAR2(90) := 'ORA-01422: la recuperación exacta devuelve un número mayor de filas que el solicitado';
BEGIN
    SELECT * INTO VAR_FILA FROM ALL_TABLES;
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO TB_ERRORES
            VALUES (SYSDATE, 'PR_SELECT_MAS_UNA_FILA', 'ORA-01422', msg);
        DBMS_OUTPUT.PUT_LINE(msg);
END;