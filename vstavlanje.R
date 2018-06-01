# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")



vstavljanje.vrsta <- function(){
  
  vrste <- read.csv("vrste.csv")
  
  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery
    
    
    for (i in 1:nrow(vrste)) {
      dbSendQuery(conn, build_sql("INSERT INTO vrsta (id, ime)
                                  VALUES (", vrste[i, "id"], ", 
                                  ", vrste[i, "ime"], ")"))
    }
    
    
    
    # Rezultat dobimo kot razpredelnico (data frame)
    }, finally = {
      # Na koncu nujno prekinemo povezavo z bazo,
      # saj preveč odprtih povezav ne smemo imeti
      dbDisconnect(conn)
      # Koda v finally bloku se izvede v vsakem primeru
      # - bodisi ob koncu izvajanja try bloka,
      # ali pa po tem, ko se ta konča z napako
    })
  }
vrsta <- vstavljanje.vrsta()


vstavljanje.izdelek <- function(){
  
  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery
    
    for (i in 1:nrow(izdelki)){
      v <- izdelki[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO izdelek (id,ime,vrsta)
                                  VALUES (", v[["IZDELEK-id"]], ", ",
                                  v[["IZDELEK-ime"]], ", ",
                                  v[["VRSTA-id"]], ")"))
      
    }
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
izdelek <- vstavljanje.izdelek()


vstavljanje.trgovina <- function(){
  
  #trgovine <- read.csv("trgovine.csv", sep=";")
  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery
     


      for (i in 1:nrow(trgovine)){
        v <- trgovine[i, ]
        dbSendQuery(conn, build_sql("INSERT INTO trgovina (id,ime, naslov)
                                    VALUES (", v[["TRGOVINA-id"]], ",
                                    ",v[["TRGOVINA-ime"]], ", 
                                    ",v[["TRGOVINA-naslov"]], ")")) 

      
    }
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
trgovina <- vstavljanje.trgovina()

vstavljanje.podjetje <- function(){
  
        # Uporabimo tryCatch,
    # da prisilimo prekinitev povezave v primeru napake
    tryCatch({
      # Vzpostavimo povezavo
      conn <- dbConnect(drv, dbname = db, host = host,
                        user = user, password = password)
      
      # Poizvedbo zgradimo s funkcijo build_sql
      # in izvedemo s funkcijo dbGetQuery
      
      for (i in 1:nrow(podjetja)){
        v <- podjetja[i, ]
        dbSendQuery(conn, build_sql("INSERT INTO podjetje (id,ime, naslov, telefon)
                                    VALUES (", v[["PODJETJE-id"]], ",
                                    ",v[["PODJETJE-ime"]], ", 
                                    ",v[["PODJETJE-naslov"]], ",
                                    ",v[["PODJETJE-telefon"]], ")"))
        
 
      
      
    }
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
podjetje <- vstavljanje.podjetje()





vstavljanje.prodaja <- function(){
  
  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery
    
    for (i in 1:nrow(izdelki)){
      v <- izdelki[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO prodaja (trgovina, izdelek, ime, kolicina, cena)
                                  VALUES (", v[["TRGOVINA-id"]], ",
                                  ", v[["IZDELEK-id"]], ",
                                  ", v[["IZDELEK-ime"]], ", 
                                  ", v[["KOLIČINA"]], ", 
                                  ", v[["CENA"]], ")"))
      
      
      
    }
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
prodaja <- vstavljanje.prodaja()


vstavljanje.proizvaja <- function(){
  
  

  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery
    
    for (i in 1:nrow(izdelki)){
      v <- izdelki[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO proizvaja (podjetje, izdelek, ime, kolicina)
                                  VALUES (", v[["PODJETJE-id"]], ",
                                  ", v[["IZDELEK-id"]], ",
                                  ", v[["IZDELEK-ime"]], ", 
                                  ", v[["KOLIČINA"]], ")"))
      
    }

    
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
proizvaja <- vstavljanje.proizvaja()
  
      
#dbSendQuery(conn, build_sql(" ALTER  SEQUENCE proizvaja.id  RESTART WITH 5000 INCREMENT BY 25"))  
      
