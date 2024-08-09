

####################### DEFINIR PERIODO #######################

### Cargo librerías
source("R/00-librerias.R")

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



### Informe individual por Organismo
param_so <- unique(df_transparencia$so_nombre)[18]
param_fecha <- unique(df_transparencia$periodo)[1]
etiq_so <-tolower(str_replace_all(param_so, " ", "_")) 

rmarkdown::render(input = here("informes/report_template_x_organismo.Rmd"),
                  output_file = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                  params = list(sujeto_obligado = param_so,
                                periodo = param_fecha))

pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                       output = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.pdf")))



### Informe individual por Trimestre
param_fecha <- unique(df_transparencia$periodo)
etiq_fecha <-str_replace_all(tolower(sub("\\s*\\(.*$", "", param_fecha)), " ", "_")

rmarkdown::render(input = here("informes/report_template_trimestral.Rmd"),
                  output_file = here(glue("salidas/salidas_reportes/{today()}_{etiq_fecha}.html")),
                  params = list(periodo = param_fecha))

pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/{today()}_{etiq_fecha}.html")),
                       output = here(glue("salidas/salidas_reportes/{today()}_{etiq_fecha}.pdf")))



######### Reporte automatizado por organismo #########

for (so in seq_along(unique(df_transparencia$so_nombre))) {
  
  param_so <- unique(df_transparencia$so_nombre)[so]
  param_fecha <- unique(df_transparencia$periodo)[1]
  etiq_so <- tolower(str_replace_all(param_so, " ", "_"))
  
  withCallingHandlers({
    
  rmarkdown::render(input = here("informes/report_template_x_organismo.Rmd"),
                    output_file = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                    params = list(sujeto_obligado = param_so,
                                  periodo = param_fecha))
  
  pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/por_sujeto_obligado/{today()}_{etiq_so}.html")),
                         output = here(glue("salidas/salidas_reportes/por_sujeto_obligado/{today()}_{etiq_so}.pdf")))
  }, error = function(e) {
    message(cli::cli_alert_warning("Cuidado, el reporte para el {param_so} no se pudo ejecutar correctamente. Revisar."))
  })
}

