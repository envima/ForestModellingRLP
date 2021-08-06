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

# source function 002 and 003

# 1. read stack & polygons
# 2. predict 
# 4. 


# 1- extraction
#------------------------------

summerRLP <- stack("data/Sentinel_RLP/summerRLP.grd")
winterRLP <- stack("data/Sentinel_RLP/winterRLP.grd")
summerIndices <- stack("data/Sentinel_RLP/indicesSummerRLP.grd")
winterIndices <- stack("data/Sentinel_RLP/indicesWinterRLP.grd")

# rename bands
names(summerRLP) = paste0(names(summerRLP), "_summer")
names(winterRLP) = paste0(names(winterRLP), "_winter")
names(summerIndices) = paste0(names(summerIndices), "_summer")
names(winterIndices) = paste0(names(winterIndices), "_winter")

RLPsen <- raster::stack(summerRLP, winterRLP, summerIndices, winterIndices)
rasterStack

#---------------------
# polygone

rlp_forest = st_read("data/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.shp")
rlp_forest = st_transform(rlp_forest, crs = 25832)


# extraction of selected variables

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

testRun = balancing(extr = data,
                    response = "BAGRu",
                    class = c("Fi", "Ei", "Ki", "Bu", "Dou"))


# 2 - modelling
#--------------



#



