
### Importo base de datos
ruta <- "bases/"
archivo <- "V. FINAL Formulario de relevamiento - Índice de Transparencia 2024 (respuestas).xlsx"
df_transparencia_orig <- read_excel(paste0(ruta, archivo))

### Importo diccionario para nombre de variables
dicc_variables <- read_excel("bases/Diccionarios.xlsx")
dicc_equivalencias <- read_excel("bases/Diccionarios.xlsx", sheet = "equivalencia_items_subitems")
