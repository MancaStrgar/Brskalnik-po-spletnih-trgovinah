library(dplyr)
library(readr)
library(rvest)
library(tidyr)
library(digest)


uvoz <- function() {
  tab <- read_csv2(file="izdelki.csv",
                    locale = locale(encoding = "Windows-1250"), skip = 1,  n_max = 810)

  colnames(tab) <- c("IZDELEK-ime","IZDELEK-id","KOLIČINA","CENA","VRSTA-ime","VRSTA-id",
                      "TRGOVINA-ime","TRGOVINA-id","TRGOVINA-naslov","PODJETJE-ime","PODJETJE-id", "PODJETJE-naslov","PODJETJE-telefon")
  return(tab)
}
izdelki <- uvoz()

