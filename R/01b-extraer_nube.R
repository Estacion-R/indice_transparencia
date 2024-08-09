
# Cargo librerías
source("R/00-librerias.R")


#################################### CARGO BASE DESDE LA NUBE
# Seteo opciones para abrir con mail validado
correo <- "usuario@correo.com"

options(
  gargle_oauth_cache = ".secrets",
  gargle_oauth_email = TRUE
)

# Seteo .secrets ya configurado y mail de acceso
googledrive::drive_auth(cache = ".secrets", email = correo)


### link de google drive a la planilla de google drive con los datos del relevamiento
url <- "https://docs.google.com/spreadsheets/d/11ZrCH7zhPrUPUsQmxlmRlsfiUlXKzhcnhvM_bxgLan8/edit?gid=2020022958#gid=2020022958"


df_transparencia_orig <- googlesheets4::read_sheet(url)



### Importo diccionario para nombre de variables
dicc_variables <- read_excel(here("bases/Diccionarios.xlsx"))
dicc_equivalencias <- read_excel(here("bases/Diccionarios.xlsx"), 
                                 sheet = "equivalencia_items_subitems")


## Escribo base importada de GoogleDrive
readr::write_csv(df_transparencia_orig, glue::glue("bases/{lubridate::today()}_CRUDA-formulario_relevamiento.csv"))
