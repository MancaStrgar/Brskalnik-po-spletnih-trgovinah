library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("superhero"),
                  
  
  titlePanel("Brskalnik po spletnih trgovinah"),

  mainPanel(
    tabsetPanel(
      tabPanel("Iskanje po trgovini",

             sidebarPanel(
                uiOutput("izborTrgovine"),
                uiOutput("izborVrste"),
                uiOutput("iskanjeIzdelka2")
               ),
              mainPanel(tableOutput("izdelki"))
      ),
      
      tabPanel("Iskanje po kategoriji",
               
               sidebarPanel(
                 uiOutput("izborVrste4"),
                 uiOutput("iskanjeIzdelka_vrsta")
               ),
               mainPanel(tableOutput("izdelki4"))
      ),
     
      tabPanel("Iskanje po izdeleku",
               
               sidebarPanel(
                 uiOutput("iskanjeIzdelka5"),
                 uiOutput("iskanjeIzdelka25"),
                 
                 sliderInput("min_max",
                             "cena:",
                             min = 0,
                             max = 50,
                             value = c(0,50),
                             step = 0.1,
                             post = "€",
                             sep = ".")
               ),
               mainPanel(tableOutput("izdelki5"))
      ),
      
    
      tabPanel("Iskanje po podjetju",
               
               sidebarPanel(
                 uiOutput("iskanjeIzdelka250"),
                 uiOutput("iskanjeIzdelka8")
               ),
               mainPanel(tableOutput("izdelki50"))
      )
      
     
  )
  )

))


