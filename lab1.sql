-- LAB 1: 25 Febrero 2020
-- Joaquin Terrasa Moya

-- [1] Muestre el nombre y el tipo de los atributos de la tabla ALUMNOS del usuario DOCENCIA
SELECT COLUMN_NAME as Nombre, DATA_TYPE as tipo
FROM ALL_TAB_COLUMNS
WHERE OWNER = 'DOCENCIA'
AND TABLE_NAME = 'ALUMNOS';

-- [2] Listar el nombre y tipo de todos los objetos del usuario conectado
SELECT OBJECT_NAME as Nombre, OBJECT_TYPE as tipo
FROM ALL_OBJECTS
WHERE owner = 'DOCENCIA';

-- [3] Mostrar los roles que el usuario tienen actualmente activados
SELECT *
FROM dba_role_privs
WHERE grantee = 'DOCENCIA';

-- [4] Listar los privilegios de sistema asignados al usuario conectado
SELECT *
FROM DBA_SYS_PRIVS
WHERE grantee = 'DOCENCIA';

-- [5] Listar los nombres de restricciones foráneas a tablas del mismo esquema que tiene el usuario DOCENCIA
SELECT constraint_name as Nombre
FROM all_constraints
WHERE owner = 'DOCENCIA'
AND table_name = 'DEPARTAMENTOS'
AND constraint_type = 'P';

-- [6] Lista, ordenado por el nombre de tabla todas las columnas, su tipo y su longitud del esquema DOCENCIA
SELECT TABLE_NAME as NOMBRETABLA, COLUMN_NAME as NOMBRECOLUMNA, DATA_TYPE as TIPODATOS, DATA_LENGTH as LONGITUD
FROM ALL_TAB_COLUMNS
WHERE OWNER = 'DOCENCIA'
ORDER BY TABLE_NAME DESC;

-- [7] Listar el nombre de las vistas que a su vez dependen de otras vistas. Mostrar también el nombre de esas otras vistas de las que dependen.
SELECT OWNER, NAME, TYPE, REFERENCED_OWNER as R_OWNER, REFERENCED_NAME as R_NAME, 
       REFERENCED_TYPE as R_TYPE, REFERENCED_LINK_NAME as R_LINK, DEPENDENCY_TYPE as DEP_TYPE
    FROM DBA_DEPENDENCIES
    WHERE TYPE = 'VIEW'
    AND REFERENCED_TYPE = 'VIEW';

-- [8] Listar el nombre de todas las vistas de usuarios que comiencen por UBD y que son INVALIDAS
SELECT OBJECT_NAME as OBJETO FROM ALL_OBJECTS
    WHERE (
        OWNER LIKE 'UBD%' AND
        OBJECT_TYPE = 'VIEW' AND
        STATUS = 'INVALID'
    );

-- [9] Listar las Integridad referencial de las tablas del esquema DOCENCIA. Es decir, listar el nombre de la tabla, columna y nombre de la restricción foránea.
SELECT TABLE_NAME as TABLA_NOMBRE, COLUMN_NAME as COLUMN_NOMBRE, CONSTRAINT_NAME as RESTRICCION_NOMBRE
    FROM ALL_CONS_COLUMNS
    WHERE OWNER = 'DOCENCIA';

-- [10] Seleccionar todas las vistas del usuario DOCENCIA basadas en una consulta larga (más de 150 caracteres).
SELECT * FROM ALL_VIEWS
    WHERE OWNER = 'DOCENCIA' AND
    TEXT_LENGTH > 150;

-- [11] Mostrar todos los índices marcados como únicos (UNIQUENESS='UNIQUE') del usuario DOCENCIA junto al número de columnas que lo forman.
SELECT ai.INDEX_NAME as Nombre,
       (SELECT COUNT(*) FROM ALL_IND_COLUMNS aic WHERE ai.INDEX_NAME = aic.INDEX_NAME) as Numero
    FROM ALL_INDEXES ai
    WHERE ai.OWNER = 'DOCENCIA'
    AND ai.UNIQUENESS = 'UNIQUE';

-- ========================================================================
-- Code from the lab

SELECT * from all_ind_columns where index_owner = 'DOCENCIA';
SELECT * FROM all_objects WHERE owner = 'DOCENCIA' and object_name = 'PROFESORES'