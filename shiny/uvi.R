library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Brskalnik po spletnih trgovinah"),
  
  tabsetPanel(
    tabPanel("Število priseljenih",
             sidebarPanel(
               selectInput("drzava",
                           label = "Izberite državo",
                           choices = sort(unique(tabela2$Drzava_drzavljanstva)),
                           selected = "Slovenija"),
               selectInput("spol",
                           label = "Izberite spol",
                           choices = sort(unique(tabela2$Spol))
               )
             ),
             mainPanel(plotOutput("tabela2"))
    ),
    tabPanel("Število odseljenih",
             sidebarPanel(
               selectInput("drzava1",
                           label = "Izberite državo",
                           choices = sort(unique(html1$Drzava_prihodnjega_prebivalisca))
                           ),
               selectInput("spol1",
                           label = "Izberite spol",
                           choices = sort(unique(html1$Spol))
               )
             ),
             mainPanel(plotOutput("html1"))
    )
  )
))
