

################################################## Tablas IT output

### Hoja 1
salida_hoja1 <- df_transparencia |> 
  distinct(periodo, so_tipo, so_nombre, item_tipo, preg_numero, prom_subitem, pond_componente, pond_indice) |> 
  mutate(indice_ta = case_when(item_tipo == "TA" ~ prom_subitem * pond_componente),
         indice_tp = case_when(item_tipo == "TP" ~ prom_subitem * pond_componente),
         indice_total = prom_subitem * pond_indice) |> 
  summarise(TA = sum(indice_ta, na.rm = T) * 100,
            TP = sum(indice_tp, na.rm = T) * 100,
            IT = sum(indice_total, na.rm = T)* 100,
            .by = c(periodo, so_tipo, so_nombre)) |>
  mutate(across(where(is.numeric), \(x) round(x, digits = 1))) |> 
  rename("Período" = periodo,
         "Tipo de SO" = so_tipo,
         "Sujeto obligado" = so_nombre)


### Hoja 2
salida_hoja2 <- df_transparencia |> 
  filter(item_tipo == "TA") |> 
  distinct(periodo, so_tipo, so_nombre, preg_numero, prom_subitem) |> 
  slice_head(n = 1, by = c(periodo, so_tipo, so_nombre, preg_numero)) |> 
  left_join(dicc_equivalencias, by = c("preg_numero" = "codigo")) |> 
  mutate(equivalencia = paste0(preg_numero, ". ", equivalencia)) |> 
  select(-preg_numero) |> 
  pivot_wider(names_from = "equivalencia", 
              values_from = "prom_subitem") |> 
  rename("Período" = periodo,
         "Tipo de SO" = so_tipo,
         "Sujeto obligado" = so_nombre) |> 
  left_join(salida_hoja1 |> 
              select(`Sujeto obligado`, TA), 
            by = "Sujeto obligado")


### Hoja 3
salida_hoja3 <- df_transparencia |> 
  filter(item_tipo == "TP") |> 
  distinct(periodo, so_tipo, so_nombre, preg_numero, prom_subitem) |> 
  slice_head(n = 1, by = c(periodo, so_tipo, so_nombre, preg_numero)) |> 
  left_join(dicc_equivalencias, by = c("preg_numero" = "codigo")) |> 
  mutate(equivalencia = paste0(preg_numero, ". ", equivalencia)) |> 
  select(-preg_numero) |> 
  pivot_wider(names_from = "equivalencia", 
              values_from = "prom_subitem") |> 
  rename("Período" = periodo,
         "Tipo de SO" = so_tipo,
         "Sujeto obligado" = so_nombre) |> 
  left_join(salida_hoja1 |> 
              select(`Sujeto obligado`, TP), 
            by = "Sujeto obligado")


### Hoja 4
# Tot
total_general <- salida_hoja1 |> summarise(TA = mean(TA)) |> pull(TA)

salida_hoja4 <- salida_hoja1 |> 
  group_by("Tipo SO" = `Tipo de SO`) |> 
  summarise(TA = mean(TA)) |> 
  add_row(`Tipo SO` = "Total general", TA = total_general)



### Hoja 5
# Tot
total_general <- salida_hoja1 |> summarise(TP = mean(TP)) |> pull(TP)

salida_hoja5 <- salida_hoja1 |> 
  group_by("Tipo SO" = `Tipo de SO`) |> 
  summarise(TP = mean(TP)) |> 
  add_row(`Tipo SO` = "Total general", TP = total_general)



### Hoja 6
salida_hoja6 <- salida_hoja2 |> 
  group_by(`Tipo de SO`) |> 
  summarise(across(4:ncol(salida_hoja2)-1, \(x) mean(x, na.rm = T))) |> 
  select(-TA)


### Hoja 7
salida_hoja7 <- salida_hoja3 |> 
  group_by(`Tipo de SO`) |> 
  summarise(across(4:ncol(salida_hoja3)-1, \(x) mean(x, na.rm = T))) |> 
  select(-TP)


output_tablas_it <- list(
  "tabla 1" = salida_hoja1,
  "tabla 2" = salida_hoja2,
  "tabla 3" = salida_hoja3,
  "tabla 4" = salida_hoja4,
  "tabla 5" = salida_hoja5,
  "tabla 6" = salida_hoja6,
  "tabla 7" = salida_hoja7
)

writexl::write_xlsx(output_tablas_it, glue::glue("salidas/output_visualizaciones_{today()}.xlsx"))

