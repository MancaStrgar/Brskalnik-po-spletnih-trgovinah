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
                               ime TEXT NOT NULL ,
                               naslov TEXT NOT NULL ,
                               telefon TEXT NOT NULL )"))
  
  dbSendQuery(conn, build_sql("CREATE TABLE izdelek (
                               id SERIAL PRIMARY KEY,
                               ime TEXT NOT NULL,
                               pakiranje TEXT NOT NULL,
                               vrsta INTEGER NOT NULL REFERENCES vrsta(id))"))
  
  dbSendQuery(conn, build_sql("CREATE TABLE prodaja (
                              id SERIAL PRIMARY KEY,
                              trgovina INTEGER NOT NULL REFERENCES trgovina(id),
                              izdelek INTEGER NOT NULL REFERENCES izdelek(id),
                              cena TEXT NOT NULL)"))
  
  dbSendQuery(conn, build_sql("CREATE TABLE proizvaja (
                              id SERIAL PRIMARY KEY,
                              podjetje INTEGER NOT NULL REFERENCES podjetje(id),
                              izdelek INTEGER NOT NULL REFERENCES izdelek(id))"))
  
  
  
                        
  # Rezultat dobimo kot razpredelnico (data frame)
}, finally = {
  # Na koncu nujno prekinemo povezavo z bazo,
  # saj preveč odprtih povezav ne smemo imeti
  dbDisconnect(conn)
  # Koda v finally bloku se izvede v vsakem primeru
  # - bodisi ob koncu izvajanja try bloka,
  # ali pa po tem, ko se ta konča z napako
})

pravice <- function(){
  # Uporabimo tryCatch,(da se povežemo in bazo in odvežemo)
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,#drv=s čim se povezujemo
                      user = user, password = password)
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2018_mancas TO klemenh WITH GRANT OPTION"))

    dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO klemenh WITH GRANT OPTION"))

    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO klemenh WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO mancas WITH GRANT OPTION"))
   
    
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO klemenh WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO mancas WITH GRANT OPTION"))
   
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2018_mancas TO javnost"))
    dbSendQuery(conn, build_sql("GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost"))
    
    
    
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn) #PREKINEMO POVEZAVO
    # Koda v finally bloku se izvede, preden program konča z napako
  })
}
pravice()
  
  
 