# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake

tryCatch({
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  
  # Poizvedbo zgradimo s funkcijo build_sql
  # in izvedemo s funkcijo dbGetQuery
  
  dbSendQuery(conn, build_sql("CREATE TABLE vrsta (
                               id INTEGER PRIMARY KEY,
                               ime TEXT NOT NULL)"))
  dbSendQuery(conn, build_sql("CREATE TABLE trgovina (
                               id INTEGER PRIMARY KEY,
                               ime TEXT NOT NULL,
                               naslov TEXT NOT NULL)"))
  dbSendQuery(conn, build_sql("CREATE TABLE podjetje (
                               id INTEGER PRIMARY KEY,
                               ime TEXT NOT NULL,
                               naslov TEXT NOT NULL,
                               telefon TEXT NOT NULL)"))
  dbSendQuery(conn, build_sql("CREATE TABLE izdelek (
                               id SERIAL PRIMARY KEY,
                               ime TEXT NOT NULL,
                               vrsta INTEGER NOT NULL REFERENCES vrsta(id))"))
  
  dbSendQuery(conn, build_sql("CREATE TABLE prodaja (
                              id SERIAL PRIMARY KEY,
                              izdelek INTEGER NOT NULL REFERENCES izdelek(id),
                              ime TEXT NOT NULL,
                              kolicina TEXT NOT NULL,
                              cena TEXT NOT NULL,
                              vrsta INTEGER NOT NULL REFERENCES vrsta(id),
                              podjetje INTEGER NOT NULL REFERENCES podjetje(id))"))
                        
  # Rezultat dobimo kot razpredelnico (data frame)
}, finally = {
  # Na koncu nujno prekinemo povezavo z bazo,
  # saj preveč odprtih povezav ne smemo imeti
  dbDisconnect(conn)
  # Koda v finally bloku se izvede v vsakem primeru
  # - bodisi ob koncu izvajanja try bloka,
  # ali pa po tem, ko se ta konča z napako
})
  
  
  
 