
library(shiny)
library(dplyr)
library(RPostgreSQL)

library(shiny)
# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)


source("auth_public.R")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake
tryCatch({
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)



shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabelo
  izd <- dbGetQuery(conn, build_sql("SELECT ime, vrsta FROM izdelek"))
  
  output$izdelek <- renderTable({
    # Naredimo poizvedbo
    # x %>% f(y, ...) je ekvivalentno f(x, y, ...)
    t <- izd %>% filter(vrsta = input$vrsta) %>% data.frame()
    # Čas izpišemo kot niz
    # Vrnemo dobljeno razpredelnico
    t
  })
  
})

}, finally = {
  # Na koncu nujno prekinemo povezavo z bazo,
  # saj preveč odprtih povezav ne smemo imeti
  dbDisconnect(conn)
  # Koda v finally bloku se izvede v vsakem primeru
  # - bodisi ob koncu izvajanja try bloka,
  # ali pa po tem, ko se ta konča z napako
})

