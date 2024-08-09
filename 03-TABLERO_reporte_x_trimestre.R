
source("R/00-librerias.R")
source("R/00-funciones.R")

#################################### Cargo ultima base limpia ####################################
ultima_base <- max(list.files(here("bases/"), pattern = "LIMPIA"))

df_transparencia <- read_csv(here(glue("bases/{ultima_base}")))

### Setear el trimestre deseado para ejecutar el informe, en base a las siguientes opciones:
unique(df_transparencia$periodo)

# Ejemplo: 
# param_fecha <- "2° Trimestre 2024 (Abril - Junio)"

param_fecha <- "Ubicar aquí el nombre del trimestre que figura en la base, al correr el unique()"


#################################### Informe individual por Trimestre ####################################


### Informe individual por Trimestre
etiq_fecha <-str_replace_all(tolower(sub("\\s*\\(.*$", "", param_fecha)), " ", "_")

  rmarkdown::render(input = here("informes/report_template_trimestral.Rmd"),
                    output_file = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.html")),
                    params = list(periodo = param_fecha))
  
  pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.html")),
                         output = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.pdf")))

