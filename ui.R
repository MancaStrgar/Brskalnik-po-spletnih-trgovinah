
library(shiny)
# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake
tryCatch({
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)

shinyUI(fluidPage(
  
  titlePanel("Brskalnik po spletnih trgovinah"),
  
  
  tabsetPanel(
    tabPanel("Spar",
             sidebarPanel(
               selectInput("vrsta",
                           label = "Izberite vrsto",
                           choices = dbGetQuery(conn, build_sql("SELECT ime FROM vrsta"))
                           #SELECT izdelek.ime, vrsta.id FROM izdelek JOIN vrsta ON izdelek.vrsta= vrsta.id
             ),
             mainPanel(tableOutput("izdelek"))
    )
    ))
  ))
  
  ##sidebarLayout(
  #  sidebarPanel(
  #    sliderInput("vrsta",
  #                "Izberite vrsto izdelka:",
  #                min = -10000,
  #                max = 10000,
  #                value = 1000)
  #  ),
  ##  mainPanel(
  #    tableOutput("transakcije")
  #  )
  #)
#))



}, finally = {
  # Na koncu nujno prekinemo povezavo z bazo,
  # saj preveč odprtih povezav ne smemo imeti
  dbDisconnect(conn)
  # Koda v finally bloku se izvede v vsakem primeru
  # - bodisi ob koncu izvajanja try bloka,
  # ali pa po tem, ko se ta konča z napako
})
