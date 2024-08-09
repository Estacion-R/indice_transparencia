
source("R/00-librerias.R")
source("R/00-funciones.R")

#################################### Cargo ultima base limpia ####################################
ultima_base <- max(list.files(here("bases/"), pattern = "LIMPIA"))
df_transparencia <- read_csv(here(glue("bases/{ultima_base}")))

### Setear el trimestre deseado para ejecutar el informe, en base a las siguientes opciones:
unique(df_transparencia$periodo)

# Ejemplo: 
# param_fecha <- "2° Trimestre 2024 (Abril - Junio)"

param_fecha <- "setear"



#################################### Informe individual por Organismo ####################################
# Elegir uno de los sujetos obligados entre los siguientes:
unique(df_transparencia$so_nombre)

# Ejemplo:
# param_so <- "Universidad Nacional de Pilar"

param_so <- "seleccionar sujeto obligado aca"

# Esto se ejecuta sólo, NO EDITAR
etiq_so <-tolower(str_replace_all(param_so, " ", "_"))



### base específica para el sujeto obligado y periodo
df_transparencia_so <- df_transparencia |>
  filter(so_nombre == param_so) |> 
  filter(periodo == param_fecha)

rmarkdown::render(input = here("informes/report_template_x_organismo.Rmd"),
                  output_file = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                  params = list(sujeto_obligado = param_so,
                                periodo = param_fecha))

pagedown::chrome_print(input = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.html")),
                       output = here(glue("salidas/salidas_reportes/{today()}_{etiq_so}.pdf")))



# ------------------------------------------------------------------------------------------------#


#################################### Armo reporte automático p/c/organismo ##################

# NO ES NECARIO EDITAR NINGUN ASPECTO DEL CODIGO.
# Este código corre para todos los organismos de forma automática.

for (so in seq_along(unique(df_transparencia$so_nombre))) {
  
  # Seteo de parámetros 
  param_so <- unique(df_transparencia$so_nombre)[so]
  etiq_so <- tolower(str_replace_all(param_so, " ", "_"))
  
  # Ejecuto los informes. Esto puede demorar un tiempo, dependiendo de cuántos sujetos obligados se trate.
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