

####################### DEFINIR PERIODO #######################

### Cargo librerías
source(here::here("R/00-librerias.R"))

### Importo base cruda
source(here::here("R/01-extraer.R"))

### Preparo base 
source(here::here("R/02-transformar.R"))



##### Lista de sujetos obligados:
# unique(df_transparencia$so_nombre)
param_so <- unique(df_transparencia$so_nombre)[7]

##### Lista de Períodos:
# unique(df_transparencia$periodo)[1]
param_fecha <- unique(df_transparencia$periodo)[1]

##### codigo de sujeto obligado
etiq_so <-tolower(str_replace_all(param_so, " ", "_")) 



####################### GENERO REPORTE #######################
rmarkdown::render(input = here("informes/report_template_x_organismo.Rmd"),
                  output_file = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                  params = list(sujeto_obligado = param_so,
                                periodo = param_fecha))

pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                       output = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.pdf")))

