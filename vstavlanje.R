# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")



vstavljanje.vrsta <- function(){

vrsta <- read.csv("vrsta.csv")

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake
tryCatch({
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  
  # Poizvedbo zgradimo s funkcijo build_sql
  # in izvedemo s funkcijo dbGetQuery


  for (i in 1:nrow(vrsta)) {
    dbSendQuery(conn, build_sql("INSERT INTO vrsta (id, ime)
                                 VALUES (", vrsta[i, "id"], ", 
                                 ", vrsta[i, "ime"], ")"))
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
      t <- dbGetQuery(conn, build_sql("INSERT INTO izdelek (ime,vrsta)
                                    VALUES (", v[["IZDELEK-ime"]], ", ",
                                      v[["VRSTA-id"]], ")
                                    RETURNING id"))
      izdelki[i, "IZDELEK-id"] <- t$id
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



vstavljanje.podjetje <- function(){
  
  podjetje <- read.csv("podjetje.csv", sep=";")
  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery
    
    for (i in 1:nrow(izdelki)){
      dbSendQuery(conn, build_sql("INSERT INTO podjetje (id, ime, naslov, telefon)
                                      VALUES (", podjetje[i, "id"], ", 
                                             ", podjetje[i, "ime"], ", 
                                              ", podjetje[i, "naslov"], ", 
                                          ", podjetje[i, "telefon"], ")"))
                                     
    
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


vstavljanje.trgovina <- function(){
  
  trgovine <- read.csv("trgovine.csv", sep=";")
  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery
    
    for (i in 1:nrow(izdelki)){
      dbSendQuery(conn, build_sql("INSERT INTO trgovina (id, ime,naslov)
                                      VALUES (", trgovine[i, "id"], ", 
                                      ", trgovine[i, "ime"], ", 
                                 ", trgovine[i, "naslov"], ")"))
      
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
