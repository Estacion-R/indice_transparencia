

################################################## Tablas IT output
### Tabla 1
salida_tabla_1 <- df_transparencia |> 
  select(periodo, so_tipo, so_nombre, TA, TP, IT) |> 
  mutate(across(where(is.numeric), \(x) round(x, digits = 1))) |> 
  rename("Período" = periodo,
         "Tipo de SO" = so_tipo,
         "Sujeto obligado" = so_nombre)


### Tabla 2
salida_tabla_2 <- df_transparencia |> 
  select(periodo, so_tipo, so_nombre, preg_1:preg_13, TA) |> 
  mutate(across(where(is.numeric), \(x) round(x, digits = 1))) |>
  pivot_longer(cols = preg_1:preg_13, 
               names_to = "pregunta", 
               values_to = "valor") |> 
  mutate(pregunta = str_remove_all(pregunta, "preg_"),
         pregunta = as.numeric(pregunta)) |> 
  left_join(dicc_equivalencias, by = c("pregunta" = "codigo"))  |> 
  mutate(equivalencia = paste0(pregunta, ". ", equivalencia)) |> 
  select(-pregunta) |> 
  pivot_wider(names_from = "equivalencia", 
              values_from = "valor") |> 
  relocate(TA, .after = starts_with("13.")) |> 
  rename("Período" = periodo,
         "Tipo de SO" = so_tipo,
         "Sujeto obligado" = so_nombre) 


### Tabla 3
salida_tabla_3 <- df_transparencia |> 
  select(periodo, so_tipo, so_nombre, preg_14:preg_20, TP) |> 
  mutate(across(where(is.numeric), \(x) round(x, digits = 1))) |>
  pivot_longer(cols = preg_14:preg_20, 
               names_to = "pregunta", 
               values_to = "valor") |> 
  mutate(pregunta = str_remove_all(pregunta, "preg_"),
         pregunta = as.numeric(pregunta)) |> 
  left_join(dicc_equivalencias, by = c("pregunta" = "codigo"))  |> 
  mutate(equivalencia = paste0(pregunta, ". ", equivalencia)) |> 
  select(-pregunta) |> 
  pivot_wider(names_from = "equivalencia", 
              values_from = "valor") |> 
  relocate(TP, .after = starts_with("13.")) |> 
  rename("Período" = periodo,
         "Tipo de SO" = so_tipo,
         "Sujeto obligado" = so_nombre) 


### Hoja 4
# Tot
total_general <- salida_tabla_1 |> summarise(TA = mean(TA)) |> pull(TA)

salida_tabla_4 <- salida_tabla_1 |> 
  group_by("Tipo SO" = `Tipo de SO`) |> 
  summarise(TA = mean(TA)) |> 
  add_row(`Tipo SO` = "Total general", TA = total_general)



### Tabla 5
# Tot
total_general <- salida_tabla_1 |> summarise(TP = mean(TP)) |> pull(TP)

salida_tabla_5 <- salida_tabla_1 |> 
  group_by("Tipo SO" = `Tipo de SO`) |> 
  summarise(TP = mean(TP)) |> 
  add_row(`Tipo SO` = "Total general", TP = total_general)



### Tabla 6
salida_tabla_6 <- salida_tabla_2 |> 
  group_by(`Tipo de SO`) |> 
  summarise(across(4:ncol(salida_tabla_2)-1, \(x) mean(x, na.rm = T))) |> 
  select(-TA)

salida_tabla_6 <- bind_rows(salida_tabla_6,
                            salida_tabla_6 %>%
                            summarise(across(where(is.numeric), mean)) |> 
                            mutate("Tipo de SO" = "Total") |> 
                            relocate("Tipo de SO"))

### Tabla 7
salida_tabla_7 <- salida_tabla_3 |> 
  group_by(`Tipo de SO`) |> 
  summarise(across(4:ncol(salida_tabla_3)-1, \(x) mean(x, na.rm = T))) |> 
  select(-TP)

salida_tabla_7 <- bind_rows(salida_tabla_7,
                          salida_tabla_7 %>%
                            summarise(across(where(is.numeric), mean)) |> 
                            mutate("Tipo de SO" = "Total") |> 
                            relocate("Tipo de SO"))


output_tablas_it <- list(
  "tabla 1" = salida_tabla_1,
  "tabla 2" = salida_tabla_2,
  "tabla 3" = salida_tabla_3,
  "tabla 4" = salida_tabla_4,
  "tabla 5" = salida_tabla_5,
  "tabla 6" = salida_tabla_6,
  "tabla 7" = salida_tabla_7
)

writexl::write_xlsx(output_tablas_it, glue::glue("salidas/output_visualizaciones_{today()}.xlsx"))

