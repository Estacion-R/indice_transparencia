
salida_bbdd_resultados <- df_transparencia |> 
  select(-cant_item_TA, -cant_item_TP) |> 
  rename(
    "Período" = periodo,
    "Tipo de SO" = so_tipo,
    "Sujeto obligado" = so_nombre,
    "Pondera_TA" = pondera_ta_subindice,
    "Pondera_Tpa" = pondera_tp_subindice_a,
    "Pondera_Tpb" = pondera_tp_subindice_b,
    "Pondera_IT-TA" = pondera_ta_indice,
    "Pondera_IT-Tpa" = pondera_tp_indice_a,
    "Pondera_IT-Tpb" = pondera_tp_indice_b)


salida_bbdd_relevamiento <- df_transparencia_limpia |> 
  select(-preg_3.a, -preg_3.b, -preg_3.c,
         -preg_4.a, -preg_4.b, -preg_4.c,
         -preg_10.a, -preg_10.b, -preg_10.c)


### Exporto tabla
output_bbss_datos_abiertos <- list(
  "BBDD_relevamiento" = salida_bbdd_relevamiento,
  "BBDD_resultados" = salida_bbdd_resultados)

writexl::write_xlsx(output_bbss_datos_abiertos, glue::glue("salidas/output_datos_abiertos_{today()}.xlsx"))
