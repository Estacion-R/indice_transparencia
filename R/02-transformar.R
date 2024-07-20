
##################################### Preparo base de trabajo
df_transparencia <- df_transparencia_orig


# Renombro variables
# Chequeo consistencia entre el diccionario de variables y las columnas que tiene la base de datos
if(length(colnames(df_transparencia)) == length(dicc_variables$nombre_de_variable)){
  
  colnames(df_transparencia) <- dicc_variables$nombre_de_variable
  
  df_transparencia <- df_transparencia |> 
    relocate(so_pertenencia, .before = "1.a")
  
  colnames(df_transparencia)[10:84] <- paste0("preg_", colnames(df_transparencia)[10:84])
  
} else {
  cli::cli_alert_danger("Las columnas del diccionario no coinciden con las columnas de la base importada")
}


## Limpi columna fechas
df_transparencia <- df_transparencia |> 
  mutate(periodo = case_when(periodo == "ABRIL (Enero - Marzo 2024)" ~ "1° Trimestre 2024",
                             periodo == "1° Trimestre 2024 (Enero - Marzo)" ~ "1° Trimestre 2024",
                             periodo == "JULIO (Abril - Junio 2024)" ~ "2° Trimestre 2024",
                             .default = periodo))


### Elimino duplicados para mismo período, quedándome con la última marca temporal registrada por cada sujeto oblg.
df_transparencia <- df_transparencia |> 
  slice_max(marca_temporal, 
            by = c(universidades, empresas_publicas, entes_sec_pub_nac, 
                   org_descentralizados, admin_central_desconcentrada)) |> 
  select(-link, -nombre_apellido_respondente, -fecha_relevamiento)


# - Armo columna única con nombre de organismo
df_transparencia <- df_transparencia |> 
  mutate(
    so_nombre = case_when(!is.na(admin_central_desconcentrada) ~ admin_central_desconcentrada,
                          !is.na(universidades) ~ universidades,
                          !is.na(empresas_publicas) ~ empresas_publicas,
                          !is.na(entes_sec_pub_nac) ~ entes_sec_pub_nac,
                          !is.na(org_descentralizados) ~ org_descentralizados)) |> 
  relocate(so_nombre, .after = so_tipo) |> 
  select(periodo, so_nombre, so_tipo,
         starts_with("preg_"))


# - Codifico variable de respuesta a númerica
df_transparencia <- df_transparencia |> 
  mutate(
    across(starts_with("preg_"), \(x) case_when(x %in% c("Si", "Actualizado") ~ 1,
                                                x == "Parcialmente" ~ 0.5,
                                                x %in% c("No", "Desactualizado", "Desactualizada") ~ 0,
                                                x %in% c("No corresponde", "Valor nulo") ~ NA_real_)))

### Armo los promedios para las preguntas que tienen índice y subìndice: 3, 4 y 10
df_transparencia_limpia <- df_transparencia |> 
  group_by(so_nombre) |> 
  mutate(preg_3.a = mean(c(preg_3.i.a, preg_3.ii.a), na.rm = T),
         preg_3.b = mean(c(preg_3.i.b, preg_3.ii.b), na.rm = T),
         preg_3.c = mean(c(preg_3.i.c, preg_3.ii.c), na.rm = T),
         preg_4.a = mean(c(preg_4.i.a, preg_4.ii.a), na.rm = T),
         preg_4.b = mean(c(preg_4.i.b, preg_4.ii.b), na.rm = T),
         preg_4.c = mean(c(preg_4.i.c, preg_4.ii.c), na.rm = T),
         preg_10.a = mean(c(preg_10.i.a, preg_10.ii.a), na.rm = T),
         preg_10.b = mean(c(preg_10.i.b, preg_10.ii.b), na.rm = T),
         preg_10.c = mean(c(preg_10.i.c, preg_10.ii.c), na.rm = T)) |> 
  relocate(preg_3.a, preg_3.b, preg_3.c, .after = preg_2.c) |> 
  relocate(preg_4.a, preg_4.b, preg_4.c, .after = preg_3.c) |> 
  relocate(preg_10.a, preg_10.b, preg_10.c, .after = preg_9.c) |> 
  ungroup()

pond_x_cantidad_de_items <- df_transparencia_limpia |> 
  #select(so_nombre, preg_1.a:preg_13.c) |> 
  pivot_longer(cols = starts_with("preg_"), names_to = "pregunta", values_to = "respuesta") |> 
  separate(col = "pregunta", into = c("preg_numero", "preg_item", "preg_subitem"), sep = "\\.") |> 
  mutate(preg_numero = parse_number(preg_numero),
         item_tipo = case_when(preg_numero %in% c(1:13) ~ "TA",
                               preg_numero > 13 ~ "TP"))


# Armo base para estimación de cantidad de ítems por sujeto obligado
pond_x_cantidad_de_items <- pond_x_cantidad_de_items |> 
  group_by(so_nombre) |> 
  mutate(denominador_pond = case_when(preg_numero != 20 & (preg_item == "a" | preg_subitem == "a") & !is.na(respuesta) ~ 1,
                                      .default = 0))

pond_x_cantidad_de_items <- pond_x_cantidad_de_items |> 
  group_by(so_nombre, preg_numero, item_tipo) |> 
  summarise(max = max(denominador_pond))

pond_x_cantidad_de_items <- pond_x_cantidad_de_items |> 
  group_by(so_nombre, item_tipo) |> 
  summarise(cant_items = sum(max)) |> 
  pivot_wider(names_from = item_tipo, values_from = cant_items, names_prefix = "cant_item_")


# Agrego las columnas de cantidad de items a la base de trabajo
df_transparencia <- df_transparencia_limpia |> 
  left_join(pond_x_cantidad_de_items, by = "so_nombre")


# Armo promedios por índice
df_transparencia <- df_transparencia |> 
  group_by(so_nombre) |> 
  mutate(preg_1 = mean(c(preg_1.a, preg_1.b, preg_1.c), na.rm = TRUE),
         preg_2 = mean(c(preg_2.a, preg_2.b, preg_2.c), na.rm = TRUE),
         preg_3 = mean(c(preg_3.a, preg_3.b, preg_3.c), na.rm = TRUE),
         preg_4 = mean(c(preg_4.a, preg_4.b, preg_4.c), na.rm = TRUE),
         preg_5 = mean(c(preg_5.a, preg_5.b, preg_5.c), na.rm = TRUE),
         preg_6 = mean(c(preg_6.a, preg_6.b, preg_6.c), na.rm = TRUE),
         preg_7 = mean(c(preg_7.a, preg_7.b, preg_7.c), na.rm = TRUE),
         preg_8 = mean(c(preg_8.a, preg_8.b, preg_8.c), na.rm = TRUE),
         preg_9 = mean(c(preg_9.a, preg_9.b, preg_9.c), na.rm = TRUE),
         preg_10 = mean(c(preg_10.a, preg_10.b, preg_10.c), na.rm = TRUE),
         preg_11 = mean(c(preg_11.a, preg_11.b, preg_11.c), na.rm = TRUE),
         preg_12 = mean(c(preg_12.a, preg_12.b, preg_12.c), na.rm = TRUE),
         preg_13 = mean(c(preg_13.a, preg_13.b, preg_13.c), na.rm = TRUE),
         preg_14 = mean(c(preg_14.a, preg_14.b, preg_14.c), na.rm = TRUE),
         preg_15 = mean(c(preg_15.a, preg_15.b, preg_15.c), na.rm = TRUE),
         preg_16 = mean(c(preg_16.a, preg_16.b, preg_16.c), na.rm = TRUE),
         preg_17 = mean(c(preg_17.a, preg_17.b, preg_17.c), na.rm = TRUE),
         preg_18 = mean(c(preg_18.a, preg_18.b, preg_18.c), na.rm = TRUE),
         preg_19 = mean(c(preg_19.a, preg_19.b, preg_19.c), na.rm = TRUE),
         # preg_20_a = mean(c(preg_20.a.a, preg_20.b.a, preg_20.c.a), na.rm = TRUE),
         # preg_20_e = mean(c(preg_20.a.e, preg_20.b.e, preg_20.c.e), na.rm = TRUE),
         # preg_20_U = mean(c(preg_20.a.u, preg_20.b.u, preg_20.c.u), na.rm = TRUE)),
         preg_20 = mean(c(preg_20.a.a, preg_20.b.a, preg_20.c.a, 
                          preg_20.a.u, preg_20.b.u, preg_20.c.u,
                          preg_20.a.u, preg_20.b.u, preg_20.c.u), na.rm = TRUE)) |> 
  select(periodo, so_tipo, so_nombre, 
         preg_1:preg_20, 
         cant_item_TA, cant_item_TP)

### Armo promedios
df_transparencia <- df_transparencia |> 
  group_by(so_nombre) |> 
  mutate(pondera_ta_subindice =  1/cant_item_TA,
         pondera_tp_subindice_a =  0.5/cant_item_TP,
         pondera_tp_subindice_b = 0.5,
         pondera_ta_indice = 0.9/cant_item_TA,
         pondera_tp_indice_a = 0.05/cant_item_TP,
         pondera_tp_indice_b = 0.05) |> 
  ungroup()

df_transparencia <- df_transparencia |> 
  mutate(across(where(is.numeric), \(x) coalesce(x, 0))) |> 
  mutate(TA = ((preg_1 * pondera_ta_subindice) + (preg_2 * pondera_ta_subindice) +
               (preg_3 * pondera_ta_subindice) + (preg_4 * pondera_ta_subindice) +
               (preg_5 * pondera_ta_subindice) + (preg_6 * pondera_ta_subindice) +
               (preg_7 * pondera_ta_subindice) + (preg_8 * pondera_ta_subindice) +
               (preg_9 * pondera_ta_subindice) + (preg_10 * pondera_ta_subindice) +
               (preg_11 * pondera_ta_subindice) + (preg_12 * pondera_ta_subindice) +
               (preg_13 * pondera_ta_subindice)) * 100,
         TP = ((preg_14 * pondera_tp_subindice_a) + (preg_15 * pondera_tp_subindice_a) +
                 (preg_16 * pondera_tp_subindice_a) + (preg_17 * pondera_tp_subindice_a) +
                 (preg_18 * pondera_tp_subindice_a) + (preg_19 * pondera_tp_subindice_a) +
                 (preg_20 * pondera_tp_subindice_b)) * 100,
         IT = (
           ((preg_1 * pondera_ta_indice) + (preg_2 * pondera_ta_indice) +
             (preg_3 * pondera_ta_indice) + (preg_4 * pondera_ta_indice) +
             (preg_5 * pondera_ta_indice) + (preg_6 * pondera_ta_indice) +
             (preg_7 * pondera_ta_indice) + (preg_8 * pondera_ta_indice) +
             (preg_9 * pondera_ta_indice) + (preg_10 * pondera_ta_indice) +
             (preg_11 * pondera_ta_indice) + (preg_12 * pondera_ta_indice) +
             (preg_13 * pondera_ta_indice)) 
           +
             ((preg_14 * pondera_tp_indice_a) + (preg_15 * pondera_tp_indice_a) +
                (preg_16 * pondera_tp_indice_a) + (preg_17 * pondera_tp_indice_a) +
                (preg_18 * pondera_tp_indice_a) + (preg_19 * pondera_tp_indice_a) +
                (preg_20 * pondera_tp_indice_b))
           ) * 100)
           
            
## Escribo base limpia
readr::write_csv(df_transparencia, glue::glue("bases/{lubridate::today()}_LIMPIA-formulario_relevamiento.csv"))
