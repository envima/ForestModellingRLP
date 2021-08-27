#' sub control script for data preparation
#'
#'
#' @description Use this script for controlling the processing.
#'
#' @author [name], [email@com]
#'

library(envimaR)
library(rprojroot)
root_folder = find_rstudio_root_file()

source(file.path(root_folder, "src/functions/000_setup.R"))


# 1. read stack & polygons
# 2. predict 
# 4. 


# 1 - extraction ####
#-------------------#

# 1.1 - load sentinel data ####
#-----------------------------#

summer <- terra::rast("data/sentinel/summer/summer.tif")
winter <- terra::rast("data/sentinel/winter/winter.tif")
lidar <- terra::rast("data/lidar/LIDAR.tif")
# stack all
RLP <- terra::rast(list(summer, winter, lidar))

# 1.2 - load forest inventory data ####
#-------------------------------------#

pol = sf::read_sf("data/FID/Trainingsgebiete_RLP.gpkg")
#pol = st_transform(rlp_forest, crs = 25832)


# 1.3 - extract ####
#------------------#

rlpExtr = extraction(rasterStack = RLP, 
                     pol = pol, 
                     bufferSize = -20, 
                     idColName = "FAT__ID")


write.csv(p, "data/RLP_extration_protocoll.csv", quote = FALSE, row.names = FALSE)


# foramting of extraction

res = result[sapply(result, is.data.frame)]
res = do.call(rbind, res)
saveRDS(res, "data/RLP_extract.RDS")





#--------------------------
# extraction of selected variables
#
#
#
#
#
#
#
#
# input
lstModels = list.files(envrmt$models, pattern=c(".RDS"), full.names = FALSE)
predictors <- terra::rast(list(summerRLP, winterRLP, summerIndices, winterIndices))

selected_variables()


# 2 - balancing the data ####
#---------------------------#

# input
extr = readRDS(file.path("data/model_training_data/RLP_extract.RDS"))
polygons = st_read("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Exp_Shape_Wefl_UTM/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.shp") %>% st_drop_geometry()
polygons = polygons[,c("FAT__ID", "Phase", "BAGRu")]
extr = merge(extr, polygons, by = "FAT__ID")
rm(polygons)

data = extr
rm(extr)

#####
#
#  Main Modell data balancing 
#
###########
main = balancing(extr = data,
                    response = "BAGRu",
                    class = c("Fi", "Ei", "Ki", "Bu", "Dou"))

saveRDS(file.path(main, envrmt$model_training_data, paste0("main", ".RDS")))
##
#
# diverse model data balancing
#
##
diverse = balancing(extr = data,
                    response = "BAGRu",
                    class = c("Fi", "Ei", "Ki", "Bu", "Dou", "Lbk", "Lbl", "Lä"))

saveRDS(diverse, file.path(envrmt$model_training_data, paste0("diverse", ".RDS")))
##
#
# successional stages balancing
#
#
data = data %>% filter(Phase != "Etb")
data$Quality = paste0(data$BAGRu, "_", data$Phase)


for (i in unique(data$BAGRu)) {
  i = unique(data$BAGRu)[1]
  df = data %>% filter(BAGRu == i)
  quality = balancing(extr = df,
                      response = "Quality",
                      class = unique(df$Quality))
  
  saveRDS(quality, file.path(envrmt$model_training_data, paste0(i, ".RDS")))
}


# 2 - modelling
#--------------



#



