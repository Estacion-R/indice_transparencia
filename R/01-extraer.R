
# Cargo librerías
source("R/00-librerias.R")

# Seteo opciones para abrir con mail validado
correo <- "pablotiscornia@estacion-r.com"
#correo <- "pablotisco@gmail.com" 

options(
  gargle_oauth_cache = ".secrets",
  gargle_oauth_email = TRUE
)

# Seteo .secrets ya configurado y mail de acceso
googledrive::drive_auth(cache = ".secrets", email = correo)

### base 1er trimestre
#url <- "https://docs.google.com/spreadsheets/d/11ZrCH7zhPrUPUsQmxlmRlsfiUlXKzhcnhvM_bxgLan8/edit?gid=2020022958#gid=2020022958"

### base 2do trimestre
url <- "https://docs.google.com/spreadsheets/d/1aYmyX8BYWa6LkLUJ1jmhNclEeATprSJo2hafZ9xpwjI/edit?gid=1506311575#gid=1506311575"

#df_transparencia_orig <- googlesheets4::read_sheet(url)


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
