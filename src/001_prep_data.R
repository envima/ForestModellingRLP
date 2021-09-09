#' sub control script for data preparation
#'
#'
#' @description Use this script for controlling the processing.
#'
#' @author [name], [email@com]
#'


# 0 - set up ####
#---------------#

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

# 1.1 - download sentinel data ####
#---------------------------------#

# use conda environment with earth engine to download Sentinel-2 data
use_condaenv("gee-demo", conda = "auto",required = TRUE)
ee$Initialize() # Trigger the earth engine authentication

# Download Sentinel-2 data at Level 2A
download_sentinel(startdate = "2019-06-21", 
                  enddate = "2019-06-30", 
                  borderFilePath = file.path(envrmt$border, "border_buffer_200m.gpkg"),
                  MaxCloud = 2,
                  outfilePath = file.path(envrmt$summer, "/"))

# Download Sentinel-2 data at Level 2A
download_sentinel(startdate = "2019-02-21", 
                  enddate = "2019-02-30", 
                  borderFilePath = file.path(envrmt$border, "border_buffer_200m.gpkg"),
                  MaxCloud = 2,
                  outfilePath = file.path(envrmt$winter, "/"))


# 1.2 - prepare Sentinel data ####
#--------------------------------#


for (i in c("summer", "winter")) {
  
#  prepSentinel(resolution = 20,
 #              folderNames = list.files(envrmt[[i]], full.names = TRUE),
  #             fileNames = list.files(envrmt[[i]], full.names = FALSE),
   #            outputPath = envrmt[[i]])
  
  sentinel = merge_crop_raster(listOfFiles = list.files(envrmt[[i]], pattern = glob2rx("*.grd"), full.names = TRUE),
                               border = read_sf(file.path(envrmt$border, "border_buffer_200m.gpkg")),
                               borderCrs = TRUE,
                               buffer = 200)
  
  ind = sentinelIndices(filePath = sentinel,
                        outPath = file.path(envrmt[[i]], paste0("sentinel_", i, ".grd")),
                        suffix = paste0("_", i))
  
}


# 2. Hansen forest cover ####
#---------------------------#

download_hansen(borderFilePath = file.path(envrmt$border, "border_buffer_200m.gpkg"))
  
# 2.1 - download hansen data treecover, gain and loss ####
#--------------------------------------------------------#

#load data tiles to list
lstHansen = list(
  c(list.files(file.path(envrmt$hansen), pattern = "treecover2000", full.names = TRUE)),
  c(list.files(file.path(envrmt$hansen), pattern = "loss", full.names = TRUE)),
  c(list.files(file.path(envrmt$hansen), pattern = "gain", full.names = TRUE)))

#hansen = list()
#for (i in 1:length(lstHansen)) {
#  hansen[[i]] = merge_crop_raster(listOfFiles = lstHansen[[i]],
#                                  border = read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Landesgrenze_RLP/Landesgrenze_RLP.shp"),
#                                  changeBorderCrs = TRUE,
#                                  buffer = 200)
#}


forestMask = prep_hansen(treeCover = rast(lstHansen[[1]]),
                         loss = rast(lstHansen[[2]]),
                         gain = rast(lstHansen [[3]]),
                         changeCRS = "epsg:25832")
# same resolution as Sentinel:
forestMask = terra::mask(forestMask, vect(sf::read_sf(file.path(envrmt$border, "border_buffer_200m.gpkg"))))

# safe raster
terra::writeRaster(forestMask, file.path(envrmt$hansen, "forestMask.tif"), overwrite = TRUE)

rm(lstHansen, forestMask)


# 3 - forest inventory data ####
#------------------------------#

fid = prep_forest_inventory(FID = sf::read_sf(file.path(envrmt$FID, "wefl_UTM_BAZ.shp")),
                            forestMask = terra::rast(file.path(envrmt$hansen, "forestMask.tif")),
                            identicalCrs = FALSE,
                            purity = 80,
                            purityCol = "proz",
                            idCol = "FAT__ID")

sf::write_sf(fid, file.path(envrmt$FID, "FID_filtered.gpkg"))


