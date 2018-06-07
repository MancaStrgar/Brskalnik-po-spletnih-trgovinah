library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Brskalnik po spletnih trgovinah"),
  

  mainPanel(
    #uiOutput('mytabs'),
    tabsetPanel(
      tabPanel("Trgovina",

             sidebarPanel(
                uiOutput("izborTrgovine"),
                uiOutput("izborVrste"),
                uiOutput("iskanjeIzdelka"),
                uiOutput("iskanjeIzdelka2")
               ),
    
              mainPanel(tableOutput("izdelki"))
    
      ),
      tabPanel("Vrsta", "Tu ni nicesar"
      )
      
  )
  )

))


