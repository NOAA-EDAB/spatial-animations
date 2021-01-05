library(survdat)

channel = dbutils::connect_to_database(server='',uid = '')
data = survdat::get_survdat_data(channel)
spp = survdat::get_species(channel)
saveRDS(data,here::here('data-raw','survdat.Rds'))
saveRDS(spp,here::here('data-raw','survdat_spp.Rds'))
