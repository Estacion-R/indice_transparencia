# Flujo de trabajo para el cálculo del Índice de Transparencia

> Objetivo: Estandarizar y automatizar el procesamiento de datos para la estimación del índicador en cuestión.

<br>

## Estructura de carpeta y descripción de las mismas

- [archivo:](archivo) Repositorio para archivos, scripts o documentos obsoletos.
- [bases:](bases) Carpeta donde ubicar la base de datos con los sujetos obligados relevados.
- [docs:](docs) Espacio para alojar archivos que no sean parte del procesamiento, como documentos metodológicos, archivos auxiliares, etc.
- [informes:](informes) Aquí se ubican:
  - Modelos de informes a ser consumidos por el procesamiento para generar reportes de resultados por sujeto obligado, trimestre y semestre
  - [informe_portadas:](informes/informe_portadas) Portadas a ser utilizadas por estos modelos de reporte
  - [control_calidad](informes/control_calidad) Posibles reportes de calidad a diseñar para ejecutar sobre la base de datos
- [R:](R) Aquí se ubican los scripts que conforman el procesamiento de datos en sí, pasando por las principales etapas del flujo de trabajo: importar --> limpiar --> transformar --> visualizar --> exportar
- [salidas:](salidas) En esta carpeta se alojan:
  - [bases_limpias:](salidas/bases_limpias) bases de trabajo, una vez ejecutado el proceso de importación y transformación de los datos. Estas bases serań los insumos para los tabulados y reportes.
  - [salidas_reportes:](salidas/salidas_reportes) 
    - [por_sujeto_obligado:](salidas/salidas_reportes/por_sujeto_obligado) Informes creados por sujeto obligado
    - [por_trimestre:](salidas/salidas_reportes/por_trimestre) Informes creados por trimestre
    - [por_semestre:](salidas/salidas_reportes/por_semestre) Informes creados por semestre

<br>

### Set de archivos para ejecutar el procesamiento:

- El primer paso es ejecutar el archivo [01-TABLERO_limpieza_y_tablas.R](01-TABLERO_limpieza_y_tablas.R)
  - Las principales tareas desarrolladas en este script son:
    - Importar los datos (de forma local o a través de la nube). 
    - Transformar y limpiar los datos
    - Generar los tabulados para _visualización_ y _datos abiertos_

- Una vez realizado el primer paso, se puede ejecutar (en cualquier orden), cualquiera de los siguientes scripts, en función de las necesidades concretas del momento:
  -  [REPORTES - por_sujeto_obligado.R](REPORTES - por_sujeto_obligado.R) desde donde se podrá correr un informe de forma individual por un __sujeto obligado__ en específico o de forma automática para todos los __sujetos obligados__ de la base de datos
  -  [REPORTES - por_trimestre.R](REPORTES - por_trimestre.R) desde donde se podrá correr un informe de forma individual por un __trimestre__ en específico o de forma automática para todos los __trimestres__ de la base de datos
  -  [REPORTES - por_semestre.R](REPORTES - por_semestre.R) desde donde se podrá correr un informe de forma individual por un __semestre__ en específico o de forma automática para todos los __semestre__ de la base de datos
