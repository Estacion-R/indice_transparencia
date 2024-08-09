limpio_texto <- function(text) {
  text <- gsub("[\'\"]", "", text)
  return(text)
}
