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
# crs for all the data: "epsg:25832"!
#
#+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no

# 1 - Sentinel data ####
#----------------------#

#data: sentinel tiles; source: https://scihub.copernicus.eu/dhus/#/home
#                              winter: Sentinel-2B. Tiles: 2019/02/27: T31UGR, T32ULA, T32ULB, T32ULV, T32UMB
#                                                         2019/02/24: T32UMA, T32UMV
#                              summer: Sentinel-2B. Tiles: 2019/06/27: T31UGR, T32ULA, T32ULB, T32ULV, T32UMB
#                                                         2019/06/24: T32UMV, T32UMA, 
#                                                          
#                     polygon of RLP with buffer of 200m, source: https://opendata-esri-de.opendata.arcgis.com/datasets/esri-de-content::landesgrenze-rlp/data


for (i in c("summer", "winter")) {
  
  prepSentinel(resolution = 20,
               folderNames = list.files(envrmt[[i]], full.names = TRUE),
               fileNames = list.files(envrmt[[i]], full.names = FALSE),
               outputPath = envrmt[[i]])
  
  sentinel = merge_crop_raster(listOfFiles = list.files(envrmt[[i]], pattern = glob2rx("*.grd"), full.names = TRUE),
                               border = read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Landesgrenze_RLP/Landesgrenze_RLP.shp"),
                               borderCrs = TRUE,
                               buffer = 200)
  
  ind = sentinelIndices(filePath = sentinel,
                        outPath = file.path(envrmt[[i]], paste0("sentinel_", i, ".grd")),
                        suffix = paste0("_", i))
  
}


# 2. Hansen forest cover ####
#---------------------------#


#load data tiles to list
lstHansen = list(
  c(list.files(file.path(envrmt$hansen), pattern = "treecover2000", full.names = TRUE)),
  c(list.files(file.path(envrmt$hansen), pattern = "lossyear", full.names = TRUE)),
  c(list.files(file.path(envrmt$hansen), pattern = "gain", full.names = TRUE)))

hansen = list()
for (i in 1:length(lstHansen)) {
  hansen[[i]] = merge_crop_raster(listOfFiles = lstHansen[[i]],
                                  border = read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Landesgrenze_RLP/Landesgrenze_RLP.shp"),
                                  changeBorderCrs = TRUE,
                                  buffer = 200)
}


forestMask = prep_hansen(treeCover = rast(hansen[[1]]),
                         loss = rast(hansen[[2]]),
                         gain = rast(hansen [[3]]),
                         changeCRS = "epsg:25832")
# same resolution as Sentinel:
forestMask = terra::resample(forestMask, terra::rast(file.path(envrmt$summer, "sentinel_summer.grd")))
# safe raster
terra::writeRaster(forestMask, file.path(envrmt$hansen, "forestMask.tif"), overwrite = TRUE)
rm(lstHansen, hansen, forestMask)


# 3 - forest inventory data ####
#------------------------------#


# input
#load forest management data
FID = sf::read_sf(file.path(envrmt$FID, "wefl_UTM_BAZ.shp"))
forestLoss = terra::rast(file.path(envrmt$hansen, "forestMask.tif"))
identicalCrs = FALSE
treeSpeciesPurity = 80





fid = prep_forest_inventory(FID = sf::read_sf(file.path(envrmt$FID, "wefl_UTM_BAZ.shp")),
                            forestLoss = terra::rast(file.path(envrmt$hansen, "forestMask.tif")),
                            identicalCrs = FALSE,
                            treeSpeciesPurity = 80)

sf::write_sf(wefl_WGS84_BAZ_5Loss, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ_5Loss.shp"))
wefl_WGS84_BAZ_5Loss <- sf::read_sf(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ_5Loss.shp"))


