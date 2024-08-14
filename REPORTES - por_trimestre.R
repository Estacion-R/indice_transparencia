
source("R/00-librerias.R")
source("R/00-funciones.R")

#################################### Cargo ultima base limpia ####################################
ultima_base <- max(list.files(here("bases/"), pattern = "LIMPIA"))

df_transparencia <- read_csv(here(glue("bases/{ultima_base}")))

### Setear el trimestre deseado para ejecutar el informe, en base a las siguientes opciones:
unique(df_transparencia$periodo)

# Ejemplo: 
# param_fecha <- "2° Trimestre 2024 (Abril - Junio)"
param_fecha <- "1° Trimestre 2024 (Enero – Marzo)"


#################################### Informe individual por Trimestre ####################################


### Informe individual por Trimestre
etiq_fecha <-str_replace_all(tolower(sub("\\s*\\(.*$", "", param_fecha)), " ", "_")

  rmarkdown::render(input = here("informes/report_template_trimestral.Rmd"),
                    output_file = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.html")),
                    params = list(periodo = param_fecha))
  
  pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.html")),
                         output = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.pdf")))

  
  # ------------------------------------------------------------------------------------------------#
  
  
  #################################### Armo reporte automático p/c/organismo ##################
  
  # NO ES NECARIO EDITAR NINGUN ASPECTO DEL CODIGO.
  # Este código corre para todos los organismos de forma automática.
  
  for (so in seq_along(unique(df_transparencia$periodo))) {
    
    # Seteo de parámetros 
    param_fecha <- unique(df_transparencia$periodo)[so]
    etiq_fecha <- tolower(str_replace_all(param_fecha, " ", "_"))
    
    # Ejecuto los informes. Esto puede demorar un tiempo, dependiendo de cuántos sujetos obligados se trate.
    withCallingHandlers({
      
      rmarkdown::render(input = here("informes/report_template_trimestral.Rmd"),
                        output_file = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.html")),
                        params = list(periodo = param_fecha))
      
      pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.html")),
                             output = here(glue("salidas/salidas_reportes/por_trimestre/{today()}_{etiq_fecha}.pdf")))
    }, error = function(e) {
      message(cli::cli_alert_warning("Cuidado, el reporte para el {param_so} no se pudo ejecutar correctamente. Revisar."))
    })
  }
