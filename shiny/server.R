library(shiny)
library(dplyr)
library(dbplyr)
library(RPostgreSQL)
#library(dbplyr)

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
  
#ZAVIHEK TRGOVINA
  output$izborVrste <- renderUI({
    
    izbire=dbGetQuery(conn, build_sql("SELECT ime FROM vrsta"))
    Encoding(izbire[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
    #Iskal sem bolj elegantno resitev, vendar je nisem nasel
    
    selectInput("vrsta",
                            label = "Izberite vrsto:",
                            choices = izbire,
                            selected = "zelenjava"
                )
  })
  
  output$izborTrgovine <- renderUI({
    
    izbire1=dbGetQuery(conn, build_sql("SELECT ime FROM trgovina"))
    Encoding(izbire1[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
    #Iskal sem bolj elegantno resitev, vendar je nisem nasel
    
    selectInput("trgovina",
                label = "Izberite trgovino:",
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
  


  NajdiIzdelke <- reactive({
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
    #Encoding(t[,3])="UTF-8"
    Encoding(t[,5])="UTF-8"
    
   # colnames(t)[4] = "trgovina" #preimenujem 4. stolpec
    data.frame(t[,1:3]) #samo prve stiri stolpce hocemo
  })
  
#  output$iskanjeIzdelka <-  renderUI({ #filter po izdelkih
 #   selectizeInput("izbraniIzdelki", "Izdelek", multiple = T, choices = NajdiIzdelke()[,1])
#  })
  
  output$iskanjeIzdelka2 <-  renderUI({ #filter po izdelkih
    textInput("izbraniIzdelki2", "Poiščite izdelek:")
  })
  


  output$izdelki <- renderTable({ #glavna tabela rezultatov
    tabela=NajdiIzdelke()
    izdelki= input$izbraniIzdelki
    search = input$izbraniIzdelki2
    
    if(is.null(izdelki)){
      tabela1=tabela #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela1=tabela[tabela$ime %in% izdelki,] #sicer vrni izdelke ki ustrezajo filtru
    }
    
    if(is.null(search) || search==""){
      tabela2=tabela1 #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela2=tabela1[grepl(search,tabela1$ime),]
    }
      
    tabela2
  })
  
  
  # zavihki <- c("Trgovina", "Vrsta")
  # #Ta del kode iz baze pobere vse trgovine in jih generira kot zavihke
  # output$mytabs = renderUI({ 
  # 
  #   myTabs = lapply(zavihki, tabPanel)
  #   do.call(tabsetPanel, c(myTabs,id="zavihek"))
  # })

  
  
  
  
  
  
  
  #ZAVIHEK PODJETJE


  # NajdiIzdelke7 <- reactive({
  #   #Ob zagonu shiny javlja napako, ces da teh vrednosti se ni prejel od uporabnika.
  #   #V tem primeru mu dam zelenjava/spar kot privzeto izbiro.
  #   #####
  #   
  # 
  # 
  # })
  
  #  output$iskanjeIzdelka <-  renderUI({ #filter po izdelkih
  #   selectizeInput("izbraniIzdelki", "Izdelek", multiple = T, choices = NajdiIzdelke()[,1])
  #  })
  
    output$iskanjeIzdelka27 <-  renderUI({ #filter po izdelkih
     textInput("izbraniIzdelki27", "Poiščite podjetje:")
    })
  
  
  
  output$izdelki7 <- renderTable({ #glavna tabela rezultatov
    izdelki7= input$izbraniIzdelki7
    search = input$izbraniIzdelki27
    
    sql <- "SELECT izdelek.ime, podjetje.ime FROM izdelek
    LEFT JOIN proizvaja ON proizvaja.izdelek=izdelek.id
    LEFT JOIN podjetje ON proizvaja.podjetje = podjetje.id
    -- LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina
    -- LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id 
    -- LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina
    WHERE TRUE"
    
    data <- list()
    
    if(! is.null(izdelki7)){
      #tabela17=tabela7[tabela7$podjetje %in% izdelki7,] #sicer vrni izdelke ki ustrezajo filtru
      sql <- paste(sql, "AND podjetje.ime IN (", paste(rep("?", length(izdelki7)), collapse = ", "), ")")
      data <- c(data, izdelki7)
    }
    
    if(! is.null(search) && search!=""){
      #tabela27=tabela17[grepl(search,tabela17$podjetje),]
      sql <- paste(sql, "AND podjetje.ime ILIKE ?")
      data <- c(data, paste0('%', search, '%'))
    }
    
    query <- sqlInterpolate(conn, sql, .dots = data) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    Encoding(t[,1])="UTF-8"
    Encoding(t[,2])="UTF-8"
    # Encoding(t[,5])="UTF-8"
    
    colnames(t)[2] = "podjetje" #preimenujem 4. stolpec
    data.frame(t) #samo prve stiri stolpce hocemo
  })
  
  
  
  
  
  
  
  
  
  
  
#ZAVIHEK VRSTA
  
  output$izborVrste4 <- renderUI({
    
    izbire4=dbGetQuery(conn, build_sql("SELECT ime FROM vrsta"))
    Encoding(izbire4[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
    #Iskal sem bolj elegantno resitev, vendar je nisem nasel
    
    selectInput("vrsta4",
                label = "Izberite vrsto:",
                choices = izbire4,
                selected = "zelenjava"
    )
  })
  

  
  NajdiIzdelke4 <- reactive({
    #Ob zagonu shiny javlja napako, ces da teh vrednosti se ni prejel od uporabnika.
    #V tem primeru mu dam zelenjava/spar kot privzeto izbiro.
    #####
    if (is.null(input$vrsta4)){
      IzbranaVrsta4="zelenjava"
    } else{
      IzbranaVrsta4 = input$vrsta4
    }


    
    
    sql <- "SELECT izdelek.ime, pakiranje, cena, trgovina.ime,vrsta.ime FROM izdelek
    LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id
    LEFT JOIN vrsta ON vrsta.id = izdelek.vrsta
    LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina
    WHERE vrsta.ime =?id2"
    query <- sqlInterpolate(conn, sql,id2=IzbranaVrsta4) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    Encoding(t[,1])="UTF-8"
    #Encoding(t[,3])="UTF-8"
    Encoding(t[,5])="UTF-8"
    
    colnames(t)[4] = "Trgovina" #preimenujem 4. stolpec
    data.frame(t[,1:4]) #samo prve stiri stolpce hocemo
  })
  
 # output$iskanjeIzdelka4 <-  renderUI({ #filter po izdelkih
#    selectizeInput("izbraniIzdelki4", "Izdelek", multiple = T, choices = NajdiIzdelke4()[,1])
#  })
  
  output$iskanjeIzdelka24 <-  renderUI({ #filter po izdelkih
    textInput("izbraniIzdelki24", "Poiščite izdelek:")
  })
  
  
  
  output$izdelki4 <- renderTable({ #glavna tabela rezultatov
    tabela4=NajdiIzdelke4()
    izdelki4= input$izbraniIzdelki4
    search = input$izbraniIzdelki24
    
    if(is.null(izdelki4)){
      tabela14=tabela4 #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela14=tabela4[tabela4$ime %in% izdelki4,] #sicer vrni izdelke ki ustrezajo filtru
    }
    
    if(is.null(search) || search==""){
      tabela24=tabela14 #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela24=tabela14[grepl(search,tabela14$ime),]
    }
    
    tabela24
  })
  
  #ZAVIHEK IZDELEK
  
  NajdiIzdelke5 <- reactive({
    #Ob zagonu shiny javlja napako, ces da teh vrednosti se ni prejel od uporabnika.
    #V tem primeru mu dam zelenjava/spar kot privzeto izbiro.
    #####
    
    
    sql <- "SELECT izdelek.ime, pakiranje, cena, trgovina.ime,vrsta.ime FROM izdelek
    LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id
    LEFT JOIN vrsta ON vrsta.id = izdelek.vrsta
    LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina"
    query <- sqlInterpolate(conn, sql) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    Encoding(t[,1])="UTF-8"
    #Encoding(t[,3])="UTF-8"
    Encoding(t[,5])="UTF-8"
    
    colnames(t)[4] = "Trgovina" #preimenujem 4. stolpec
    colnames(t)[5] = "Vrsta" #preimenujem 5. stolpec
    data.frame(t)
  })
  
#  output$iskanjeIzdelka5 <-  renderUI({ #filter po izdelkih
#    selectizeInput("izbraniIzdelki5", "Izdelek", multiple = T, choices = NajdiIzdelke4()[,1])
#  })
  
  output$iskanjeIzdelka25 <-  renderUI({ #filter po izdelkih
    textInput("izbraniIzdelki25", "Poiščite izdelek:")
  })
  
  
  
  output$izdelki5 <- renderTable({ #glavna tabela rezultatov
    tabela5=NajdiIzdelke5()
    izdelki5= input$izbraniIzdelki5
    search = input$izbraniIzdelki25
    
    if(is.null(izdelki5)){
      tabela15=tabela5 %>%filter(cena>input$min, cena< input$max) #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela15=tabela5[tabela5$ime %in% izdelki5,] #sicer vrni izdelke ki ustrezajo filtru
    }
    
    if(is.null(search) || search==""){
      tabela25=tabela15 #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela25=tabela15[grepl(search,tabela15$ime),]
    }
    
    tabela25
  })
  
})

