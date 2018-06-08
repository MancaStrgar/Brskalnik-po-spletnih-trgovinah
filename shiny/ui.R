library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("superhero"),
  
  titlePanel("Brskalnik po spletnih trgovinah"),
  

  mainPanel(
    #uiOutput('mytabs'),
    tabsetPanel(
      tabPanel("Iskanje po trgovini",

             sidebarPanel(
                uiOutput("izborTrgovine"),
                uiOutput("izborVrste"),
               # uiOutput("iskanjeIzdelka"),
                uiOutput("iskanjeIzdelka2")
               ),
    
              mainPanel(tableOutput("izdelki"))
    
      ),
      tabPanel("Iskanje po kategoriji",
               
               sidebarPanel(
                 #uiOutput("izborTrgovine4"),
                 uiOutput("izborVrste4"),
                # uiOutput("iskanjeIzdelka4"),
                 uiOutput("iskanjeIzdelka24")
               ),
               
               mainPanel(tableOutput("izdelki4"))
               
      ),
      tabPanel("Iskanje po podjetju",
               
               sidebarPanel(
                # uiOutput("izborPodjetja7"),
                # uiOutput("izborVrste"),
                 # uiOutput("iskanjeIzdelka"),
                 uiOutput("iskanjeIzdelka27")
               ),
               
               mainPanel(tableOutput("izdelki7"))
               
      ),
      tabPanel("Iskanje po izdeleku",
               
               sidebarPanel(
                 #uiOutput("izborTrgovine5"),
                 #uiOutput("izborVrste5"),
                 uiOutput("iskanjeIzdelka5"),
                 uiOutput("iskanjeIzdelka25"),
                 
                 
                 sliderInput("min",
                             "Minimalni znesek transakcije:",
                             min = 0,
                             max = 50,
                             value = 0,
                            step = 0.1),
                 
               
               sliderInput("max",
                           "Maximalni znesek transakcije:",
                           min = 0,
                           max = 50,
                           value =50,
                           step = 0.1)
               
               
      ),
               
               mainPanel(tableOutput("izdelki5"))
               
               
      )
  )
  )

))


