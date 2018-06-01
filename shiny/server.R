library(shiny)
library(ggplot2)

shinyServer(function(input, output) {
  output$tabela2 <- renderPlot({
    ggplot(data = tabela2 %>% filter(Drzava_drzavljanstva ==input$drzava,
                                     Spol == input$spol),
           aes(x = Leto, y = Stevilo)) +
      geom_col(color = "purple", fill = "white")
  }) 
  output$html1 <- renderPlot({
    ggplot(data = html1 %>% group_by(Drzava_prihodnjega_prebivalisca, Leto, Spol) %>%
             summarise(Stevilo = sum(Stevilo))  %>% 
             filter(Drzava_prihodnjega_prebivalisca ==input$drzava1,
                                   Spol == input$spol1),
           aes(x = Leto, y = Stevilo)) +
      geom_col(color = "blue", fill = "white") 
  })
  
})
















#library(shiny)

#shinyServer(function(input, output) {
#  output$druzine <- DT::renderDataTable({
#    dcast(druzine, obcina ~ velikost.druzine, value.var = "stevilo.druzin") %>%
#      rename(`Občina` = obcina)
#  })
#  
#  output$pokrajine <- renderUI(
#    selectInput("pokrajina", label="Izberi pokrajino",
#                choices=c("Vse", levels(obcine$pokrajina)))
#  )
#  output$naselja <- renderPlot({
#    main <- "Pogostost števila naselij"
#    if (!is.null(input$pokrajina) && input$pokrajina %in% levels(obcine$pokrajina)) {
#      t <- obcine %>% filter(pokrajina == input$pokrajina)
#      main <- paste(main, "v regiji", input$pokrajina)
#    } else {
#      t <- obcine
#    }
#    ggplot(t, aes(x = naselja)) + geom_histogram() +
#      ggtitle(main) + xlab("Število naselij") + ylab("Število občin")
#  })
#})

