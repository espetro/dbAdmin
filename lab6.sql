-- Practica 3 Nivel Fisico - Tablas Externas y Vistas Materializadas
-- Joaquin Terrasa, a 2 de Abril de 2020

-- NOTA: Las sentencias 'PRINT' por si solas no son instrucciones SQL, sino documentacion para los labs. Esto lo hago porque el linter de SQL lo colorea.
-- Si se desea ejecutar PRINT('<texto>'), entonces usar el comando SELECT '<texto>' FROM DUAL;

PRINT('Para crear una tabla externa, primero hay que dar de alta un directorio en Oracle. Para ello vamos a buscar un directorio donde el usuario de Oracle tenga acceso.
Por ejemplo, podemos usar el directorio: C:\Users\app\alumnos\Oracle')
PRINT('Escogemos C:\Users\alumnos\Oracle')

-- [1] Crear un archivo 'C:\Users\alumnos\Oracle\clientes.txt'
-- [2] Nos conectamos con el usuario system o sys.
PRINT('Desde SQLDeveloper')

-- [3] Ejecutamos:
CREATE or REPLACE DIRECTORY DIRECTORIO_EXT AS 'C:\Users\alumnos\Oracle';

-- [4] Darle permiso al usuario AUTORACLE para leer y escribir en el directorio:
GRANT READ, WRITE ON DIRECTORY DIRECTORIO_EXT to AUTORACLE;

-- [5] Conectarse como AUTORACLE. 
PRINT('CUIDADO:No crear la tabla siguiente en SYS ni en SYSTEM!!!')
-- [6] Crear la tabla CLIENTE_EXTERNO
CREATE TABLE cliente_externo
    ( cliente_id varchar2(3),
        apellido varchar2(50),
        nombre varchar2(50),
        dni varchar2(9),
        usuario varchar2(20),
        email varchar2(100),
        direccion varchar2(100),
        codigo_postal number(5)
    )
    ORGANIZATION EXTERNAL
    ( DEFAULT DIRECTORY DIRECTORIO_EXT
        ACCESS PARAMETERS
        ( RECORDS DELIMITED BY NEWLINE
          FIELDS TERMINATED BY ','
        )
        LOCATION ('clientes.txt')  
    );

 -- [7] Desde el usuario AUTORACLE, probar a ejecutar sentencias SQL para leer, modificar, insertar... Por ejemplo: SELECT * FROM CLIENTE_EXTERNO. Investigar que ocurre con cada una de ellas.
SELECT * FROM CLIENTE_EXTERNO;

PRINT('En efecto, hemos podido extraer los datos del fichero csv en una tabla')

UPDATE CLIENTE_EXTERNO
    SET CODIGO_POSTAL = 29002
    WHERE NOMBRE LIKE '%r%';

INSERT INTO CLIENTE_EXTERNO
VALUES ('010','Hutt','Jabba','28636644B','jabba','jabba@kebabhuelin.com','Central Park of Huelin', 99235);

PRINT('Aun asi, no es posible editarla (UPDATE), ni insertar datos!!')
PRINT('Esto es porque tratamos a los datos dentro de una tabla EXTERNA a la BD')

-- [8] Añadir los datos a la tabla CLIENTE de AUTORACLE desde la tabla externa. Utilice:
PRINT('Podemos ver que campos casan en ambas tablas')
DESC CLIENTE;
DESC CLIENTE_EXTERNO;

PRINT('No podemos, pues en la tabla CLIENTE, el attr "tlfo" es NOT NULL, mientras que en CLIENTE_EXTERNO no existe tal attr.')
PRINT('Una manera de hacerlo es usando valores grupales para los attrs. (tlfo, apellido2) = (0, null)')

INSERT INTO CLIENTE
SELECT CLIENTE_ID, 000000000, NOMBRE, APELLIDO, NULL, EMAIL
FROM CLIENTE_EXTERNO; 

PRINT('No olvides confirmar la transacción.')
COMMIT;

-- [9] Asegúrese de que la tabla CLIENTE tiene clave primaria. Además, hay que crear índices sobre los atributos más comunes para realizar consultas. Uno de los índices debe ser sobre una función. Compruebe ahora los índices con USER_INDEXES.
PRINT('Podemos comprobar rapidamente las restricciones sobre "CLIENTE"')
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'CLIENTE' AND CONSTRAINT_TYPE = 'P';
SELECT * FROM USER_CONS_COLUMNS WHERE TABLE_NAME = 'CLIENTE';
PRINT('Vemos que la PK es "CLIENTE_PK", asociada a la columna "IDCLIENTE"')

CREATE INDEX CLIENTE_POR_PRIMER_APELLIDO ON CLIENTE (UPPER(APELLIDO1));
CREATE INDEX CLIENTE_POR_EMAIL ON CLIENTE (UPPER(EMAIL));
PRINT('Creamos dos indices, sobre el primer apellido y sobre el email, pues son comunes para realizar busquedas. Aplicamos la funcion UPPER, pues todos los apellidos empiezan por mayuscula y siguen con minuscula-mayuscula.')

COMMIT;

SELECT * FROM USER_INDEXES WHERE TABLE_NAME = 'CLIENTE';

-- [10] ¿En qué tablespace reside la tabla CLIENTE? ¿Y los índices?
SELECT TABLESPACE_NAME FROM USER_TABLES WHERE TABLE_NAME = 'CLIENTE';
SELECT TABLESPACE_NAME FROM USER_INDEXES WHERE TABLE_NAME = 'CLIENTE';

PRINT('Podemos comprobar que para "AUTORACLE", todos sus indices estan en el tablespace mencionado')
SELECT SEGMENT_NAME, SEGMENT_TYPE FROM USER_SEGMENTS WHERE TABLESPACE_NAME = 'TS_AUTORACLE';

-- [11] Crea una Vista materializada con los datos de las facturas EMITIDAS en 2020. La vista se debe refrescar cada dia (refresco forzado).
PRINT('https://docs.oracle.com/cd/B10501_01/server.920/a96567/repmview.htm')
PRINT('https://docs.oracle.com/cd/B19306_01/server.102/b14200/statements_6002.htm')

CREATE MATERIALIZED VIEW facturas_2020
    REFRESH ON DEMAND
    START WITH SYSDATE NEXT SYSDATE + 1
    AS
    SELECT * FROM FACTURA WHERE EXTRACT(YEAR FROM FECEMISION) = 2020;

-- La consulta de la vista es (el total de las facturas para ese año y para cada cliente):
SELECT c.idcliente, c.nombre, c.apellido1, c.apellido2, f.idfactura, f.fecemision, sum(p.preciounidadventa) total
FROM cliente c
    JOIN factura f ON c.idcliente = f.CLIENTE_idcliente
    JOIN contiene co ON co.FACTURA_IDFACTURA = f.IDFACTURA 
    JOIN pieza p ON co.PIEZA_CODREF = p.CODREF
WHERE extract (year FROM f.fecemision) = 2020
GROUP BY c.idcliente, c.nombre, c.apellido1, c.apellido2, f.idfactura, f.fecemision;

PRINT('La consulta se resuelve satisfactoriamente')

-- [12] Crear un sinónimo público denominado VM_FACTURAS para el objeto creado en el apartado anterior 

-- { desde sysdba }
GRANT CREATE PUBLIC SYNONYM TO AUTORACLE

-- { desde AUTORACLE }
CREATE OR REPLACE PUBLIC SYNONYM VM_FACTURAS
FOR FACTURAS_2020;