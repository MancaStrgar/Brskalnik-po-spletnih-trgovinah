t <- dbGetQuery(conn, build_sql("INSERT INTO vrsta (id, ime)
                                 VALUES (", v[["VRSTA-id"]], ", 
                                         ", v[["VRSTA-ime"]], ")
                                 RETURNING id"))

for i in 1:nrow(izdelki){
  v <- as.list(izdelki[i, ])
  t <- dbGetQuery(conn, build_sql("INSERT INTO izdelek (ime, vrsta)
                                   VALUES (", v[["IZDELEK-ime"]], ", 
                                           ", v[["VRSTA-id"]], ")
                                   RETURNING id"))
  izdelki[i, "IZDELEK-id"] <- t$id
}