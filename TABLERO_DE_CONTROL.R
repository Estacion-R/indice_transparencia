

####################### DEFINIR PERIODO #######################

### Cargo librerías
source("R/00-librerias.R")

### Importo base cruda
source("R/01-extraer.R")

### Preparo base 
source("R/02-transformar.R")

### Genero salidas
# - Tabla de resultados para visualización [ver Tablas IT output].
source("R/03_a-salida_tablas_viz.R")

# - Base de datos en csv para publicar en datos abiertos [Bases de datos].
source("R/03_b-salida_datos_abiertos.R")



### Armado de informes
# staplr::staple_pdf(
#   input_files = c("TESTS/portadacierre-general.pdf",
#                   "TESTS/TEST_informe.pdf"),
#   output_filepath = "TESTS/informe_pegado.pdf")

param_so <- unique(df_transparencia$so_nombre)[7]
param_fecha <- unique(df_transparencia$periodo)[1]
etiq_so <-tolower(str_replace_all(param_so, " ", "_")) 

rmarkdown::render(input = here("informes/report_template_x_organismo.Rmd"),
                  output_file = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                  params = list(sujeto_obligado = param_so,
                                periodo = param_fecha))

pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                       output = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.pdf")))



######### Reporte automatizado por organismo #########

for (so in seq_along(unique(df_transparencia$so_nombre))) {
  
  param_so <- unique(df_transparencia$so_nombre)[so]
  param_fecha <- unique(df_transparencia$periodo)[1]
  etiq_so <- tolower(str_replace_all(param_so, " ", "_"))
  
  rmarkdown::render(input = here("informes/report_template_x_organismo.Rmd"),
                    output_file = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                    params = list(sujeto_obligado = param_so,
                                  periodo = param_fecha))
  
  pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                         output = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.pdf")))
}
