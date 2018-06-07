library(shiny)
library(dplyr)
library(RPostgreSQL)
library(dbplyr)

source("auth_public.R")

#Za probleme s sumniki uporabi:
original.locale <- Sys.getlocale(category="LC_CTYPE")       ## "English_Slovenia.1252" pri meni
Sys.setlocale("LC_CTYPE", "Slovenian_Slovenia.1250")     #to popravi sumnike


shinyServer(function(input, output,session) {
  # Vzpostavimo povezavo
  drv <- dbDriver("PostgreSQL") 
  conn <- dbConnect(drv, dbname = db, host = host,
                       user = user, password = password)
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'") #poskusim resiti rezave s sumniki
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  

  
  output$izborVrste <- renderUI({
    
    izbire=dbGetQuery(conn, build_sql("SELECT ime FROM vrsta"))
    Encoding(izbire[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
    #Iskal sem bolj elegantno resitev, vendar je nisem nasel
    
    selectInput("vrsta",
                            label = "Izberite vrsto",
                            choices = izbire,
                            selected = "zelenjava"
                )
  })
  
  output$izborTrgovine <- renderUI({
    
    izbire1=dbGetQuery(conn, build_sql("SELECT ime FROM trgovina"))
    Encoding(izbire1[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
    #Iskal sem bolj elegantno resitev, vendar je nisem nasel
    
    selectInput("trgovina",
                label = "Izberite trgovino",
                choices = izbire1,
                selected = "Spar"
    )
  })
  
  
  #Želiva dodati možnost vnosa besede izdelka: NE DELA
#  
#  server <- function(input, output, session) {
#    updateSelectizeInput(session, 'izdelek', choices = izbire2, server = TRUE)
 # }
#  
#  
#  output$izborIzdelka <- renderUI({
#    
#    izbire2=dbGetQuery(conn, build_sql("SELECT ime FROM izdelek"))
#    Encoding(izbire2[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
#    #Iskal sem bolj elegantno resitev, vendar je nisem nasel
#    
#    selectizeInput("izdelek",
#                label = "Poiščite izdelek",
#                choices = izbire2
#    )
#  })
  


  
  
  
  output$izdelki <- renderTable({
    # Naredimo poizvedbo
    # x %>% f(y, ...) je ekvivalentno f(x, y, ...)
    
    
    #Ob zagonu shiny javlja napako, ces da teh vrednosti se ni prejel od uporabnika.
    #V tem primeru mu dam zelenjava/spar kot privzeto izbiro.
    #####
    if (is.null(input$vrsta)){
      IzbranaVrsta="zelenjava"
    } else{
      IzbranaVrsta = input$vrsta
    }
    
    if (is.null(input$trgovina)){
      IzbranaTrgovina="Spar"
    } else{
      IzbranaTrgovina = input$trgovina
    }
    
 #   if (is.null(input$izdelek)){
 #     IzbranIzdelek="blitva"
 #   } else{
#     IzbranIzdelek = input$izdelek
#    }
#    ######
    
    
    
    sql <- "SELECT izdelek.ime, pakiranje, cena, trgovina.ime,vrsta.ime FROM izdelek
            LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id
            LEFT JOIN vrsta ON vrsta.id = izdelek.vrsta
            LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina
            WHERE trgovina.ime =?id1 AND vrsta.ime =?id2"
    query <- sqlInterpolate(conn, sql,id1=IzbranaTrgovina,id2=IzbranaVrsta) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    Encoding(t[,1])="UTF-8"
    Encoding(t[,3])="UTF-8"
    Encoding(t[,5])="UTF-8"

  

    data.frame(t)
    
  })


  zavihki <- c("Trgovina", "Vrsta")
  #Ta del kode iz baze pobere vse trgovine in jih generira kot zavihke
  output$mytabs = renderUI({ 

    myTabs = lapply(zavihki, tabPanel)
    do.call(tabsetPanel, c(myTabs,id="zavihek"))
  })

  
  
})


