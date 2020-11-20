# Script to generate species index from survdat of format of "CatchView"
library(dplyr)

#Read in survdat full species list
survdat.spp = readRDS(here::here('data-raw','survdat_spp.Rds'))$data

#Filter survdat species by ones with svspp code and common name

survdat.spp = survdat.spp %>%  
  dplyr::filter(!is.na(SVSPP)& !is.na(COMNAME) & !is.na(O_SVCONM)) %>%
  select(SVSPP,COMNAME,O_SVCONM)

#Write output

saveRDS(survdat.spp,here::here('data-raw','survey_spp_index.Rds'))
