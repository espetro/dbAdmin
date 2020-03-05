# Apuntes del TEMA 2 (Seguridad)


### Gestion de usuarios
Para poder **definir limites a la hora de crear perfiles de usuario**, hay que cambiar algunas configuraciones por defecto de la BD. En concreto, hay que modificar el parametro `RESOURCE_LIMIT`.

```sql
-- ALTER SYSTEM SET parametro = valor
ALTER SYSTEM SET RESOURCE_LIMIT = TRUE;
-- ALTER SYSTEM SET SCOPE spfile
CREATE PROFILE Perfil_1 RESOURCE_LIMIT
    IDLE_TIME 10 -- min. tiempo muerto hasta desconexion
    PASSWORD_LIFE_TIME 90 -- dias
    FAILED_LOGIN_ATTEMPTS 4;
```

#### Permisos

`UPDATE` y `ALTER`: Mientras que `ALTER` es una instruccion *DDL* y sirve para modificar los **metadatos** de la tabla, `UPDATE` es una instruccion *DML* y sirve para modificar los **datos** de la tabla.

Por defecto, cuando creas una BD, ejecutas el usuario `SYSTEM`. Lo primero es crear un usuario con permisos (para crear tablas, etc.), y crear las tablas bajo ese usuario. **Prohibido crear objetos bajo el usuario SYS**.

**Todo usuario creado, por defecto, no tiene ningún permiso** ni cuota en el tablespace que le asignes.

#### Seguridad

> La instancia `SPFILE` hace referencia al fichero de parametros del sistema de la BD. Aquí se almacenan todos los metadatos de la BD (memoria necesaria para iniciarse, espacio necesario, *path*s asociados, ...).

