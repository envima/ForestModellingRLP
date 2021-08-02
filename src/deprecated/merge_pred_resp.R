# predictors + repsonse
library(sf)

predictors = readRDS("data/modelling/RLP_extract.RDS")
predictors$ID = NULL


response = st_read("data/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.gpkg") %>% st_drop_geometry()

# show all possible responses
colnames(response)

# choose FAT__ID + responses
r = c("FAT__ID", "Phase")

# join
df = merge(predictors, response[,r], by = "FAT__ID")

