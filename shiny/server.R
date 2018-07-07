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

  
#-------------------------------------------------------------------------------------------------
      
#ZAVIHEK TRGOVINA
  output$izborVrste <- renderUI({
    
    izbira_vrste=dbGetQuery(conn, build_sql("SELECT ime FROM vrsta"))
    Encoding(izbira_vrste[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
  
    selectInput("vrsta",
                            label = "Izberite vrsto:",
                            choices = izbira_vrste,
                            selected = "zelenjava"
                )
  })
  
  output$izborTrgovine <- renderUI({
    
    izbira_trgovine=dbGetQuery(conn, build_sql("SELECT ime FROM trgovina"))
    Encoding(izbira_trgovine[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
   
    selectInput("trgovina",
                label = "Izberite trgovino:",
                choices = izbira_trgovine,
                selected = "Spar"
    )
  })
  

  NajdiIzdelke <- reactive({
    #Ob zagonu shiny javlja napako, zato mu damo zelenjava/spar kot privzeto izbiro.
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
    
    sql <- "SELECT izdelek.ime, pakiranje, cena, trgovina.ime,vrsta.ime FROM izdelek
    LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id
    LEFT JOIN vrsta ON vrsta.id = izdelek.vrsta
    LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina
    WHERE trgovina.ime =?id1 AND vrsta.ime =?id2"
    query <- sqlInterpolate(conn, sql,id1=IzbranaTrgovina,id2=IzbranaVrsta) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
   
    Encoding(t[,1])="UTF-8"
    colnames(t)[2] = "pakiranje"
    colnames(t)[3] = "cena"
    t$cena <- paste(t$cena, "€")
    data.frame(t[,1:3]) #samo prve stiri stolpce hocemo
  })
  
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
  
  
#-------------------------------------------------------------------------------------------------
  
  #ZAVIHEK PODJETJE

    output$iskanjePodjetja <-  renderUI({ #filter po izdelkih
     textInput("iskanjePodjetja", "Poiščite podjetje:")
    })
  
  
  
  output$podjetje1 <- renderTable({ #glavna tabela rezultatov
    podjetje1= input$izbraniIzdelki7
    search = input$iskanjePodjetja
    
    sql <- "SELECT izdelek.ime, podjetje.ime, pakiranje, cena, trgovina.ime FROM izdelek
    LEFT JOIN proizvaja ON proizvaja.izdelek=izdelek.id
    LEFT JOIN podjetje ON proizvaja.podjetje = podjetje.id
    LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id 
    LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina
    WHERE TRUE"
    
    data <- list()
    
    if(! is.null(podjetje1)){
      sql <- paste(sql, "AND podjetje.ime IN (", paste(rep("?", length(podjetje1)), collapse = ", "), ")")
      data <- c(data, podjetje1)
    }
    
    if(! is.null(search) && search!=""){
      sql <- paste(sql, "AND podjetje.ime ILIKE ?")
      data <- c(data, paste0('%', search, '%'))
    }
    
    query <- sqlInterpolate(conn, sql, .dots = data) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    Encoding(t[,1])="UTF-8"
    Encoding(t[,2])="UTF-8"
    Encoding(t[,5])="UTF-8"

    
    colnames(t)[2] = "podjetje"
    colnames(t)[5] = "trgovina"
    t$cena <- paste(t$cena,"€")
    data.frame(t) #samo prve stiri stolpce hocemo
  })
  
  
#-------------------------------------------------------------------------------------------------
  
#ZAVIHEK VRSTA
  
  output$izborVrste4 <- renderUI({
    
    izbira_vrste4=dbGetQuery(conn, build_sql("SELECT ime FROM vrsta"))
    Encoding(izbira_vrste4[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
    #Iskal sem bolj elegantno resitev, vendar je nisem nasel
    
    selectInput("vrsta4",
                label = "Izberite vrsto:",
                choices = izbira_vrste4,
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
    
    colnames(t)[4] = "trgovina" #preimenujem 4. stolpec
    t$cena <- paste(t$cena, "€")
    data.frame(t[,1:4]) #samo prve stiri stolpce hocemo
  })
  
  output$iskanjeIzdelka_vrsta <-  renderUI({ #filter po izdelkih
    textInput("iskanjeIzdelka_vrsta", "Poiščite izdelek:")
  })
  
  
  
  output$izdelki4 <- renderTable({ #glavna tabela rezultatov
    tabela4=NajdiIzdelke4()
    izdelki4= input$izbraniIzdelki4
    search = input$iskanjeIzdelka_vrsta
    
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
  
  
#-------------------------------------------------------------------------------------------------
  
  #ZAVIHEK IZDELEK
  
  NajdiIzdelke5 <- reactive({

    sql <- "SELECT izdelek.ime, pakiranje, cena, trgovina.ime,vrsta.ime FROM izdelek
    LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id
    LEFT JOIN vrsta ON vrsta.id = izdelek.vrsta
    LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina"
    query <- sqlInterpolate(conn, sql) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    Encoding(t[,1])="UTF-8"
    Encoding(t[,5])="UTF-8"
    
    colnames(t)[4] = "trgovina" #preimenujem 4. stolpec
    colnames(t)[5] = "vrsta" #preimenujem 5. stolpec
    data.frame(t)
  })
  

  output$iskanjeIzdelka25 <-  renderUI({ #filter po izdelkih
    textInput("izbraniIzdelki25", "Poiščite izdelek:")
  })
  
  
  
  output$izdelki5 <- renderTable({ #glavna tabela rezultatov
    tabela5=NajdiIzdelke5()
    izdelki5= input$izbraniIzdelki5
    search = input$izbraniIzdelki25
    
    if(is.null(izdelki5)){
      tabela15=tabela5 %>%filter(cena>input$min_max[1], cena<input$min_max[2]) #ce uporabnik ni filtriral izdekov, vrni celo tabelo
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
  
  
#-------------------------------------------------------------------------------------------------
  
  #KODA ZA PODJETJE2
  
  NajdiIzdelke50 <- reactive({
    #Ob zagonu shiny javlja napako, ces da teh vrednosti se ni prejel od uporabnika.
    #V tem primeru mu dam zelenjava/spar kot privzeto izbiro.
    #####
    
    
    sql <- "SELECT izdelek.ime, podjetje.ime, pakiranje, cena, trgovina.ime FROM izdelek
    LEFT JOIN proizvaja ON proizvaja.izdelek=izdelek.id
    LEFT JOIN podjetje ON proizvaja.podjetje = podjetje.id
    LEFT JOIN prodaja ON prodaja.izdelek=izdelek.id 
    LEFT JOIN trgovina ON trgovina.id=prodaja.trgovina
    WHERE TRUE"
    query <- sqlInterpolate(conn, sql) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    Encoding(t[,1])="UTF-8"
    Encoding(t[,2])="UTF-8"
    Encoding(t[,5])="UTF-8"
    colnames(t)[2] = "podjetje"
   # colnames(t)[4] = "Trgovina" #preimenujem 4. stolpec
    colnames(t)[5] = "trgovina" #preimenujem 5. stolpec
    t$cena <- paste(t$cena, "€")
    data.frame(t)
  })
  
  #  output$iskanjeIzdelka5 <-  renderUI({ #filter po izdelkih
  #    selectizeInput("izbraniIzdelki5", "Izdelek", multiple = T, choices = NajdiIzdelke4()[,1])
  #  })
  
  output$iskanjeIzdelka250 <-  renderUI({ #filter po izdelkih
    textInput("izbraniIzdelki250", "Poiščite podjetje:")
  })
  
  
  
  output$izdelki50 <- renderTable({ #glavna tabela rezultatov
    tabela50=NajdiIzdelke50()
    izdelki50= input$izbraniIzdelki50
    search = input$izbraniIzdelki250
   
    if(is.null(izdelki50)){
      tabela150=tabela50#ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela150=tabela50[tabela50$podjetje %in% izdelki50,] #sicer vrni izdelke ki ustrezajo filtru
    }
    
    if(is.null(search) || search==""){
      tabela250=tabela150 #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela250=tabela150[grepl(search,tabela150$podjetje,ignore.case = TRUE ),]
    }
    
    
    tabela250
  })
  
  
  output$iskanjeIzdelka8 <-  renderUI({ #filter po izdelkih
    textInput("iskanjeIzdelka8", "Poiščite izdelek:")
  })
  
  
  output$izdelki8 <- renderTable({ #glavna tabela rezultatov
    tabela8=NajdiIzdelke50()
    izdelki8= input$izbraniIzdelki8
    search = input$iskanjeIzdelka8
    
    if(is.null(izdelki8)){
      tabela18=tabela8 #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela18=tabela8[tabela8$ime %in% izdelki8,] #sicer vrni izdelke ki ustrezajo filtru
    }
    
    if(is.null(search) || search==""){
      tabela28=tabela18 #ce uporabnik ni filtriral izdekov, vrni celo tabelo
    } else{
      tabela28=tabela18[grepl(search,tabela18$ime),]
    }
    
    tabela28
  })
  
  
  
  
})

