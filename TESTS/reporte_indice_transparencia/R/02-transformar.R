
##################################### Preparo base de trabajo
df_transparencia <- df_transparencia_orig

# Renombro variables
colnames(df_transparencia) <- dicc_variables$nombre_de_variable

df_transparencia <- df_transparencia |> 
  relocate(so_pertenencia, .after = admin_central_desconcentrada) |> 
  select(-link, -nombre_apellido_respondente, -fecha_relevamiento) |> 
  pivot_longer(cols = 9:(ncol(df_transparencia) - 3), 
               names_to = "pregunta", values_to = "respuesta") |> 
    separate(col = "pregunta", into = c("preg_numero", "preg_item", "preg_subitem"), sep = "\\.") |> 
  mutate(
    across(.cols = where(is.character), .fns = str_trim),
    preg_numero = as.numeric(preg_numero),
    item_tipo = case_when(preg_numero %in% c(1:13) ~ "TA",
                          preg_numero > 13 ~ "TP")) |> 
  # relocate(indicador, .before = preg_numero) |> 
  relocate(item_tipo, .before = preg_numero) |> 
  mutate(
    so_nombre = case_when(!is.na(admin_central_desconcentrada) ~ admin_central_desconcentrada,
                               !is.na(universidad) ~ universidad,
                               !is.na(empr_y_entes_sec_pub_nac) ~ empr_y_entes_sec_pub_nac,
                               !is.na(org_descentralizados) ~ org_descentralizados)) |> 
  relocate(so_nombre, .after = so_tipo) |> 
  select(periodo, so_nombre, so_tipo,
         item_tipo, starts_with("preg"), respuesta) |> 
  mutate(
    respuesta_limpia = case_when(respuesta %in% c("Si", "Actualizado") ~ 1,
                                 respuesta == "Parcialmente" ~ 0.5,
                                 respuesta %in% c("No", "Desactualizado", "Desactualizada") ~ 0,
                                 respuesta %in% c("No corresponde", "Valor nulo") ~ NA_real_),
    denominador = case_when(respuesta_limpia %in% c(1, 0.5, 0) ~ 1,
                            .default = NA_real_)) |> 
  group_by(so_nombre, preg_numero) |> 
  mutate(prom_subitem = sum(respuesta_limpia, na.rm = TRUE) / sum(denominador, na.rm = TRUE),
         prom_subitem = case_when(is.na(respuesta_limpia) & is.na(denominador) ~ NA_integer_,
                                  .default = prom_subitem)) |> 
  ungroup() |> 
  group_by(so_nombre, preg_numero, preg_item) |> 
  mutate(prom_item = sum(respuesta_limpia, na.rm = TRUE) / sum(denominador, na.rm = TRUE)) |>
  ungroup() |> 
  mutate(pond_componente = case_when(item_tipo == "TA" ~ 1/13,
                                     item_tipo == "TP" & preg_numero %in% c(14:19) ~ 0.5/6,
                                     item_tipo == "TP" & preg_numero == 20 ~ 0.5),
         pond_indice = case_when(item_tipo == "TA" ~ 0.9/13,
                                 item_tipo == "TP" & preg_numero %in% c(14:19) ~ 0.05/6,
                                 item_tipo == "TP" & preg_numero == 20 ~ 0.05)) |> 
  ungroup()


