# Nivel Físico de una BD

Recordemos los niveles de una BD:
  + Nivel **Externo**: Es la visión que tienen los distintos tipos de usuarios respecto de la BD.
  + Nivel **Conceptual**: Modelos *Entidad-Relación*, así como vistas.
  + Nivel **Físico**: Estructuras dedicadas a almacenar la BD - sistema de ficheros, backups, optimizacion, seguridad...

## Conceptos generales del nivel fisico

  + ¿Se almacenan las transacciones finalizadas si hay algun error en la BD? Sí, en los *redo logs*.
  + ¿Donde se encuentran estos ficheros? Las direcciones están almacenadas en los *Ficheros de Control*.