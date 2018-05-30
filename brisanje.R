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
  dbSendQuery(conn, build_sql("DROP TABLE proizvaja CASCADE"))
  dbSendQuery(conn, build_sql("DROP TABLE prodaja"))
  dbSendQuery(conn, build_sql("DROP TABLE izdelek CASCADE"))
  dbSendQuery(conn, build_sql("DROP TABLE podjetje CASCADE"))
  dbSendQuery(conn, build_sql("DROP TABLE trgovina CASCADE"))
  dbSendQuery(conn, build_sql("DROP TABLE vrsta CASCADE"))
  #CASCADE zato da zbriše tabelo tudi če je odvisna od ene druge
  # Rezultat dobimo kot razpredelnico (data frame)
}, finally = {
  # Na koncu nujno prekinemo povezavo z bazo,
  # saj preveč odprtih povezav ne smemo imeti
  dbDisconnect(conn)
  # Koda v finally bloku se izvede v vsakem primeru
  # - bodisi ob koncu izvajanja try bloka,
  # ali pa po tem, ko se ta konča z napako
})
