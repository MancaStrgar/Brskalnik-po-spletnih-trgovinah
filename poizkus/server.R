library(shiny)
library(dplyr)
library(RPostgreSQL)

source("auth_public.R")

shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabelo
  tbl.izdelek <- tbl(conn, "izdelek")
  tbl.vrsta <- tbl(conn, "vrsta")
  
  output$izdelki <- renderTable({
    # Naredimo poizvedbo
    # x %>% f(y, ...) je ekvivalentno f(x, y, ...)
    t <- merge(tbl.izdelek, tbl.vrsta, by.tbl.izdelek=c("vrsta"), by.tbl.vrsta=c("id")) %>%
      filter(imee = input$vrsta)
    t
  })
  
})