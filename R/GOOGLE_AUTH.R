library(googledrive)
library(googlesheets4)

correo <- "pablotiscornia@estacion-r.com" 

# designate project-specific cache
options(gargle_oauth_cache = ".secrets")

# check the value of the option, if you like
gargle::gargle_oauth_cache()

# trigger auth on purpose --> store a token in the specified cache
drive_auth(email = correo)

list.files(".secrets/")


