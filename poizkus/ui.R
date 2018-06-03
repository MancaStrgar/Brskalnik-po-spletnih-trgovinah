library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Brskalnik po spletnih trgovinah"),
  
  
  tabsetPanel(
    tabPanel("Spar",
             sidebarPanel(
               selectInput("vrsta",
                           label = "Izberite vrsto",
                           choices = dbGetQuery(conn, build_sql("SELECT imee FROM vrsta"))
                           #SELECT izdelek.ime, vrsta.id FROM izdelek JOIN vrsta ON izdelek.vrsta= vrsta.id
               ),
               mainPanel(tableOutput("izdelki"))
             )
    ))
))
