
salida_bbdd_relevamiento <- df_transparencia |> 
  #filter(!is.na(prom_subitem)) |> 
  mutate(pregunta = paste(preg_numero, preg_item, preg_subitem, sep = "."),
         pregunta = str_remove_all(pregunta, ".NA")) |> 
  select(periodo, so_tipo, so_nombre, pregunta, prom_item) |> 
  pivot_wider(names_from = pregunta, values_from = prom_item)

# colnames(salida_bbdd_relevamiento) <- c("Período", "Tipo de Sujeto obligado", "Sujeto Obligado",
#                                         dicc_variables$etiqueta_de_variable[8:83])


salida_bbdd_resultados_ponderadores <- df_transparencia |> 
  mutate(Pondera_Tpa = 0.5/6,
         Pondera_Tpb = 0.5,
         "Pondera_IT-Tpa" = 0.05/6,
         "Pondera_IT-Tpb" = 0.05) |> 
  select(so_tipo, so_nombre, -preg_numero, -prom_subitem, 
         "Pondera_TA" = pond_componente,  Pondera_Tpa,  Pondera_Tpb, 
         "Pondera_IT-TA" = pond_indice, "Pondera_IT-Tpa", "Pondera_IT-Tpb") |> 
  slice_head(n = 1, by = c(so_nombre))


salida_bbdd_resultados <- df_transparencia |> 
  select(so_tipo, so_nombre, preg_numero, prom_subitem) |>
  slice_head(n = 1, by = c(so_nombre, preg_numero)) |> 
  pivot_wider(id_cols = c(so_tipo, so_nombre), 
              names_from = preg_numero, 
              values_from = prom_subitem) |> 
  left_join(salida_bbdd_resultados_ponderadores, 
            by = c("so_tipo", "so_nombre")) |> 
  rename("Tipo de SO" = so_tipo,
         "Sujeto obligado" = so_nombre) |> 
  left_join(salida_hoja1) |> 
  relocate("Período")

colnames(salida_bbdd_resultados) <- c("Período", "Tipo de SO", "Sujeto obligado", 
                                      dicc_equivalencias$equivalencia,
                                      "Pondera_TA", "Pondera_Tpa", "Pondera_Tpb", "Pondera_IT-TA", 
                                      "Pondera_IT-Tpa", "Pondera_IT-Tpb", "TA", "TP", "IT")

### Exporto tabla
output_bbss_datos_abiertos <- list(
  "BBDD_relevamiento" = salida_bbdd_relevamiento,
  "BBDD_resultados" = salida_bbdd_resultados)

writexl::write_xlsx(output_bbss_datos_abiertos, glue::glue("salidas/output_datos_abiertos_{today()}.xlsx"))
