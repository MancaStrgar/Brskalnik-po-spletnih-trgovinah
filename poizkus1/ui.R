library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Brskalnik po spletnih trgovinah"),
  

  mainPanel(
    uiOutput('mytabs'),

             sidebarPanel(
               uiOutput("izborTrgovine"),
               uiOutput("izborVrste")),
       
               mainPanel(tableOutput("izdelki"))
    
   

  )

))


