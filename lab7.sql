-- Practica 7 ABD
-- Joaquin Terrasa Moya, a 21 Abril 2020

-- (PILDORA PL/SQL)
SET SERVEROUTPUT ON;

-- [1]
DECLARE
    output_text VARCHAR2(200);
    CURSOR tablas IS SELECT TABLE_NAME, TABLESPACE_NAME FROM USER_TABLES;
BEGIN
    FOR dato IN tablas LOOP
        output_text := 'La tabla '||dato.TABLE_NAME||' pertenece al esquema '||dato.TABLESPACE_NAME||'.';
        DBMS_OUTPUT.PUT_LINE(output_text);
    END LOOP;
END;
/

-- [2]
DECLARE
    output_text VARCHAR2(200);
    CURSOR tablas IS SELECT TABLE_NAME, GRANTOR FROM DBA_TAB_PRIVS WHERE GRANTEE='UBD776';
BEGIN
    FOR dato IN tablas LOOP
        output_text := 'La tabla '||dato.TABLE_NAME||' pertenece al esquema '||dato.GRANTOR||'.';
        DBMS_OUTPUT.PUT_LINE(output_text);
    END LOOP;
END;
/

-- [3]
-- Dado que no se me han concedido acceso a tablas de otros esquemas/usuarios, no me ha hecho falta nada

-- [4]
DECLARE
    output_text VARCHAR2(200);
    CURSOR tablas IS SELECT TABLE_NAME, TABLESPACE_NAME FROM ALL_TABLES WHERE OWNER=USER;
BEGIN
    FOR dato IN tablas LOOP
        output_text := 'La tabla '||dato.TABLE_NAME||' pertenece al esquema '||dato.TABLESPACE_NAME||'.';
        DBMS_OUTPUT.PUT_LINE(output_text);
    END LOOP;
END;
/
-- No supone diferencia alguna (mirar respuesta 3).
-- Si lo aplico en otra config. de BD, donde mi USER comparta tablas, si me sirva.

-- [5]
CREATE OR REPLACE PROCEDURE RECORRE_TABLAS (
        P_MODE IN NUMBER DEFAULT NULL
    ) AS
    output_text VARCHAR2(200);
    CURSOR tablas IS SELECT TABLE_NAME, TABLESPACE_NAME, OWNER FROM ALL_TABLES;
BEGIN
    IF (P_MODE = 0) THEN
        FOR dato IN tablas LOOP
            output_text := 'La tabla '||dato.TABLE_NAME||' pertenece al esquema '||dato.TABLESPACE_NAME||'.';
            DBMS_OUTPUT.PUT_LINE(output_text);
        END LOOP;
    ELSIF (P_MODE = NULL) THEN
        DBMS_OUTPUT.PUT_LINE('Esto es un texto de ayuda.');
    ELSE
        FOR dato IN tablas LOOP
            IF dato.OWNER <> USER THEN
                output_text := 'La tabla '||dato.TABLE_NAME||' pertenece al esquema '||dato.TABLESPACE_NAME||'.';
                DBMS_OUTPUT.PUT_LINE(output_text);
            END IF;
        END LOOP;
    END IF;
END RECORRE_TABLAS;
