
source("R/00-librerias.R")
source("R/01-extraer.R")
source("R/02-transformar.R")

# for (so in unique(df_transparencia$so_nombre)) {
#   
#   etiq_so <- tolower(str_replace_all(so, " ", "_"))
#   
#   rmarkdown::render(input = "report_template.Rmd", 
#                     output_file = glue::glue("output_reportes/{etiq_so}.html"), 
#                     params = list(sujeto_obligado = so))
#   
#   pagedown::chrome_print(input = glue::glue("output_reportes/{etiq_so}.html"), 
#                          output = glue::glue("output_reportes/{etiq_so}.pdf"))
# }
