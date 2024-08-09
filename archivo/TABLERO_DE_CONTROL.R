

####################### DEFINIR PERIODO #######################

### Cargo librerías
source("R/00-librerias.R")
source("R/00-funciones.R")

### Importo base cruda
source("R/01a-extraer_local.R")
#source("R/01b-extraer_nube.R")

### Preparo base 
source("R/02-transformar.R")


### Genero salidas
# - Tabla de resultados para visualización [ver Tablas IT output].
source("R/03_a-salida_tablas_viz.R")

# - Base de datos en csv para publicar en datos abiertos [Bases de datos].
source("R/03_b-salida_datos_abiertos.R")





