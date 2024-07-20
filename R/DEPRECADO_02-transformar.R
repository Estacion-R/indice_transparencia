
##################################### Preparo base de trabajo
df_transparencia <- df_transparencia_orig

# Renombro variables
# Chequeo consistencia entre el diccionario de variables y las columnas que tiene la base de datos
if(length(colnames(df_transparencia)) == length(dicc_variables$nombre_de_variable)){
  
  colnames(df_transparencia) <- dicc_variables$nombre_de_variable
  
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
                   org_descentralizados, admin_central_desconcentrada))


# - Organizo columnas
# - elimino columnas con info de registro (link, respondente y fecha relevamiento)
# - Pivoteo tabla para mejor procesamiento
df_transparencia <- df_transparencia |> 
  relocate(so_pertenencia, .after = admin_central_desconcentrada) |> 
  select(-link, -nombre_apellido_respondente, -fecha_relevamiento) |> 
  pivot_longer(cols = 10:(ncol(df_transparencia) - 3), 
               names_to = "pregunta", values_to = "respuesta")


# - Segmento columna de pregunta por ítem y subítem
df_transparencia <- df_transparencia |> 
  separate(col = "pregunta", into = c("preg_numero", "preg_item", "preg_subitem"), sep = "\\.") |> 
  mutate(
    across(.cols = where(is.character), .fns = str_trim),
    preg_numero = as.numeric(preg_numero),
    item_tipo = case_when(preg_numero %in% c(1:13) ~ "TA",
                          preg_numero > 13 ~ "TP")) |> 
  # relocate(indicador, .before = preg_numero) |> 
  relocate(item_tipo, .before = preg_numero)


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
         item_tipo, starts_with("preg"), respuesta)


# - Codifico variable de respuesta a númerica
df_transparencia <- df_transparencia |> 
  mutate(
    respuesta_limpia = case_when(respuesta %in% c("Si", "Actualizado") ~ 1,
                                 respuesta == "Parcialmente" ~ 0.5,
                                 respuesta %in% c("No", "Desactualizado", "Desactualizada") ~ 0,
                                 respuesta %in% c("No corresponde", "Valor nulo") ~ NA_real_),
    denominador = case_when(respuesta_limpia %in% c(1, 0.5, 0) ~ 1,
                            .default = NA_real_))


# - Calculo promedios de subitems:
df_transparencia_preg3_4_10 <- df_transparencia |> 
  filter(preg_numero %in% c(3, 4, 10)) |> 
  group_by(so_nombre, preg_numero, preg_subitem) |> 
  mutate(prom_subitem = sum(respuesta_limpia, na.rm = TRUE) / sum(denominador, na.rm = TRUE),
         prom_subitem = case_when(is.na(respuesta_limpia) & is.na(denominador) ~ NA_integer_,
                                  .default = prom_subitem)) |> 
  ungroup() |> 
  group_by(so_nombre, preg_numero, preg_item) |> 
  mutate(prom_subitem = case_when(respuesta_limpia == 0 ~ NA_integer_,
                                  .default = prom_subitem)) |> 
  mutate(pregunta = paste(preg_numero, preg_item, preg_subitem, sep = "-")) |> 
  pivot_wider(names_from = "pregunta", 
              values_from = "prom_subitem")
  # mutate(prom_subitem = case_when(preg_item == "ii" ~ NA_integer_,
  #                                 .default = prom_subitem)) |>
  #filter(so_nombre == "Ministerio de Seguridad")
  #filter(so_nombre == "Universidad de Buenos Aires")

# 
# df_transparencia_preg3 <- df_transparencia |> 
#   filter(preg_numero == 3) |> 
#   group_by(so_nombre, preg_subitem) |> 
#   mutate(prom_subitem = sum(respuesta_limpia, na.rm = TRUE) / sum(denominador, na.rm = TRUE),
#          prom_subitem = case_when(is.na(respuesta_limpia) & is.na(denominador) ~ NA_integer_,
#                                   .default = prom_subitem)) |> 
#   ungroup() |> 
#   # mutate(prom_subitem = case_when(preg_item == "ii" ~ NA_integer_,
#   #                                 .default = prom_subitem)) |>
#   filter(so_nombre == "Ministerio de Seguridad")
# 
# df_transparencia_preg4 <- df_transparencia |> 
#   filter(preg_numero == 4) |> 
#   group_by(so_nombre, preg_subitem) |> 
#   mutate(prom_subitem = sum(respuesta_limpia, na.rm = TRUE) / sum(denominador, na.rm = TRUE),
#          prom_subitem = case_when(is.na(respuesta_limpia) & is.na(denominador) ~ NA_integer_,
#                                   .default = prom_subitem)) |> 
#   ungroup() |> 
#   # mutate(prom_subitem = case_when(preg_item == "ii" ~ NA_integer_,
#   #                                 .default = prom_subitem)) |>
#   filter(so_nombre == "Ministerio de Seguridad")
  
  group_by(so_nombre, preg_numero, preg_item) |> 
  mutate(prom_subitem = mean(prom_subitem, na.rm = T)) |> 
  ungroup()

# - Calculo promedios
df_transparencia_resto <- df_transparencia |> 
  filter(!preg_numero %in% c(3, 4, 10)) |> 
  group_by(so_nombre, preg_numero) |> 
  mutate(prom_subitem = sum(respuesta_limpia, na.rm = TRUE) / sum(denominador, na.rm = TRUE),
         prom_subitem = case_when(is.na(respuesta_limpia) & is.na(denominador) ~ NA_integer_,
                                  .default = prom_subitem)) |> 
  ungroup() 
  
df_transparencia <- bind_rows(
  df_transparencia_preg3_4_10, 
  df_transparencia_resto) |> 
  group_by(so_nombre, preg_numero, preg_item) |> 
  mutate(prom_item = sum(respuesta_limpia, na.rm = TRUE) / sum(denominador, na.rm = TRUE)) |>
  ungroup() |> 
  arrange(so_nombre, preg_numero)

####################################
# Armo base para estimación de cantidad de ítems por sujeto obligado
pond_x_cantidad_de_items <- df_transparencia |> 
  #filter(item_tipo == "TA") |> 
  #filter(so_nombre == "Secretaría Legal y Técnica") |> 
  group_by(so_nombre) |> 
  mutate(denominador_pond = case_when(preg_numero != 20 & (preg_item == "a" | preg_subitem == "a") & !is.na(respuesta_limpia) ~ 1,
                                      .default = 0))

pond_x_cantidad_de_items <- pond_x_cantidad_de_items |> 
  group_by(so_nombre, preg_numero, item_tipo) |> 
  summarise(max = max(denominador_pond))

pond_x_cantidad_de_items <- pond_x_cantidad_de_items |> 
  group_by(so_nombre, item_tipo) |> 
  summarise(cant_items = sum(max))

####################################

# - Pego columna con cantidad de items por sujeto obligado
df_transparencia <- df_transparencia |> 
  left_join(pond_x_cantidad_de_items, by = c("so_nombre", "item_tipo"))


# - Armo ponderadores x sujeto obligado en función de la cantidad de ítems
df_transparencia <- df_transparencia |> 
  mutate(pond_componente = case_when(item_tipo == "TA" ~ 1/cant_items,
                                     item_tipo == "TP" & preg_numero %in% c(14:19) ~ 0.5/cant_items,
                                     item_tipo == "TP" & preg_numero == 20 ~ 0.5),
         pond_indice = case_when(item_tipo == "TA" ~ 0.9/cant_items,
                                 item_tipo == "TP" & preg_numero %in% c(14:19) ~ 0.05/cant_items,
                                 item_tipo == "TP" & preg_numero == 20 ~ 0.05))

### Limpio la preg 20:
# Para Administración Central y desconcentrada, y Descentralizados:
df_p20_descentralizada <- df_transparencia |> 
  filter(so_tipo %in% c("Administración Central y Desconcentrada", "Organismos Descentralizados")) |> 
  filter(!(preg_numero == 20  & preg_subitem %in% c("e", "u")))

# Para Empresas y Entes del Sector Público Nacional
df_p20_empresas_sec_nac <- df_transparencia |> 
  filter(so_tipo %in% c("Entes del Sector Público Nacional", "Empresas Públicas")) |> 
  filter(!(preg_numero == 20  & preg_subitem %in% c("a", "u")))

# Para Universidades
df_p20_universidades <- df_transparencia |> 
  filter(so_tipo == "Universidades") |> 
  filter(!(preg_numero == 20  & preg_subitem %in% c("a", "e")))


### Vuelvo a rearmar la base de transferencias
df_transparencia <- bind_rows(
  df_p20_descentralizada,
  df_p20_empresas_sec_nac,
  df_p20_universidades
) |> 
  mutate(preg_subitem = case_when(preg_numero == 20 ~ NA_character_,
                                  .default = preg_subitem))


## Escribo base limpia
readr::write_csv(df_transparencia, glue::glue("bases/{lubridate::today()}_LIMPIA-formulario_relevamiento.csv"))
