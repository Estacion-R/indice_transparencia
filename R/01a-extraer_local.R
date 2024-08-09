

#################################### CARGO BASE DE FORMA LOCAL
### Importo base de datos de forma local (cuando no funciona el acceso directo a google drive)
ruta <- "bases/"
archivo <- "Formulario de relevamiento - Índice de Transparencia 2024 (respuestas).xlsx"
df_transparencia_orig <- read_excel(here(paste0(ruta, archivo)), sheet = 1)


### Importo diccionario para nombre de variables
dicc_variables <- read_excel(here("bases/Diccionarios.xlsx"))
dicc_equivalencias <- read_excel(here("bases/Diccionarios.xlsx"), 
                                 sheet = "equivalencia_items_subitems")


## Escribo base importada de GoogleDrive
readr::write_csv(df_transparencia_orig, glue::glue("bases/{lubridate::today()}_CRUDA-formulario_relevamiento.csv"))

cli::cli_alert_success("Base importada con éxito")