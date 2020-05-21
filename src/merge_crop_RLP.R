#date: 05.04.2020
#name: merge_crop_RLP.R
#data: sentinel tiles; source: https://scihub.copernicus.eu/dhus/#/home
#                              winter: Sentinel-2B. Tiles: 2019/02/27: T31UGR, T32ULA, T32ULB, T32ULV, T32UMB
#                                                         2019/02/24: T32UMA, T32UMV
#                              summer: Sentinel-2B. Tiles: 2019/06/27: T31UGR, T32ULA, T32ULB, T32ULV, T32UMB
#                                                         2019/06/24: T32UMV, T32UMA, 
#                                                          
#     polygon of RLP with buffer of 5km, source: https://opendata-esri-de.opendata.arcgis.com/datasets/esri-de-content::landesgrenze-rlp/data
#output: Raster winter/summer RLP 
#----------------------------------------------------------

# 1 - load libraries and working Environment
#--------------------------------------------
source(file.path(envimaR::alternativeEnvi(root_folder = "C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu"),
                 "src/setup_forest_modelling.R"))


# 2 - create one raster from sentinel tiles
#------------------------------------------

#- 2.1 winter
#-----------
# download winter tiles and save in one folder named "winter"
# read tiles in list

folderNames <- c("L2A_T32UMA_A010287_20190224T103021", # names of the folders with the images
           "L2A_T32UMV_A010287_20190224T103021",
           "L2A_T31UGR_A010330_20190227T104021",
           "L2A_T32ULB_A010330_20190227T104021",
           "L2A_T32ULV_A010330_20190227T104021",
           "L2A_T32ULA_A010330_20190227T104021",
           "L2A_T32UMB_A010330_20190227T104021") 
layerNames <- c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B09", "B11", "B12", "B8A", "B08")


#stack all bands of each image and safe as raster
  for (i in folderNames){
   rasterStacked <- raster::stack(list.files(file.path(paste0(envrmt$path_winter, "/", i, "/IMG_DATA/R60m")), pattern = glob2rx("*.jp2"), full.names = TRUE))
   B08 <- raster::stack(list.files(file.path(paste0(envrmt$path_winter, "/", i, "/IMG_DATA/R10m")), pattern = glob2rx("*.jp2"), full.names = TRUE))
   B08 <- raster::resample(B08, rasterStacked)
   rasterStacked <- raster::stack(rasterStacked, B08)
   #safe as raster
   r <- writeRaster(rasterStacked, file.path(paste0(envrmt$path_winter, "/", i, ".grd")), format="raster", overwrite = TRUE)
   hdr(r, format = "ENVI")
  }
# reproject the UTM31 Tile, in order to merge it with the others
# source: https://gis.stackexchange.com/questions/333464/re-projecting-a-raster-in-r-to-matching-resolution-crs-and-origin-but-differe
source(file.path(envrmt$path_src, "reproject_raster.R"))

Tile31UGR <- raster::brick(file.path(envrmt$path_winter, "L2A_T31UGR_A010330_20190227T104021.grd")) # tile to be reprojected
refRaster <- raster::brick(file.path(envrmt$path_winter, "L2A_T32ULA_A010330_20190227T104021.grd")) # tile with desired projection and origin
Tile31UGR <- reproject_align_raster(rast = Tile31UGR, ref_rast = refRaster)
r <- raster::writeRaster(Tile31UGR, file.path(envrmt$path_winter, "L2A_T31UGR_A010330_20190227T104021.grd"), overwrite = TRUE) #save reprojected raster
hdr(r, format = "ENVI")

# read tiles in list
listOfFiles  <- list.files(envrmt$path_winter, pattern = glob2rx("*.grd"), full.names = TRUE)

#merge all tiles
aerialBricks <- list()
for(i in listOfFiles){
  bricked <- raster::brick(i)
  aerialBricks <- c(aerialBricks, bricked)
}
aerialBricks$fun = min
winterRLP <-  do.call(raster::mosaic, aerialBricks)
#rename raster layers
for(n in 1:nlayers(winterRLP)) {
  names(winterRLP)[n] <- layerNames[n]
}

# 2.2 - summer
#-------------
folderNames <- c("L2A_T32UMV_A012003_20190624T103030",
                 "L2A_T32UMA_A012003_20190624T103030",
                 "L2A_T31UGR_A012046_20190627T104030",
                 "L2A_T32ULA_A012046_20190627T104030",
                 "L2A_T32ULB_A012046_20190627T104030",
                 #"L2A_T32ULV_A012046_20190627T104030",
                 "L2A_T32UMB_A012046_20190627T104030")


#stack all bands of each image and safe as raster
for (i in folderNames){
  rasterStacked <- raster::stack(list.files(file.path(paste0(envrmt$path_summer, "/", i, "/IMG_DATA/R60m")), pattern = glob2rx("*.jp2"), full.names = TRUE))
  B08 <- raster::stack(list.files(file.path(paste0(envrmt$path_summer, "/", i, "/IMG_DATA/R10m")), pattern = glob2rx("*.jp2"), full.names = TRUE))
  B08 <- raster::resample(B08, rasterStacked)
  rasterStacked <- raster::stack(rasterStacked, B08)
  #safe as raster
  r <- writeRaster(rasterStacked, file.path(paste0(envrmt$path_summer, "/", i, ".grd")), format="raster", overwrite = TRUE)
  hdr(r, format = "ENVI")
}
# reproject the UTM31 Tile, in order to merge it with the others
# source: https://gis.stackexchange.com/questions/333464/re-projecting-a-raster-in-r-to-matching-resolution-crs-and-origin-but-differe
source(file.path(envrmt$path_src, "reproject_raster.R"))

Tile31UGR <- raster::brick(file.path(envrmt$path_summer, "L2A_T31UGR_A012046_20190627T104030.grd")) # tile to be reprojected
refRaster <- raster::brick(file.path(envrmt$path_summer, "L2A_T32ULB_A012046_20190627T104030.grd")) # tile with desired projection and origin
Tile31UGR <- reproject_align_raster(rast = Tile31UGR, ref_rast = refRaster)
r <- raster::writeRaster(Tile31UGR, file.path(envrmt$path_summer, "L2A_T31UGR_A012046_20190627T104030.grd"), overwrite = TRUE) #save reprojected raster
hdr(r, format = "ENVI")

# read tiles in list
listOfFiles  <- list.files(envrmt$path_summer, pattern = glob2rx("*.grd"), full.names = TRUE)


#merge all tiles
aerialBricks <- list()
for(i in listOfFiles){
  bricked <- raster::brick(i)
  aerialBricks <- c(aerialBricks, bricked)
}
aerialBricks$fun = min
summerRLP <-  do.call(raster::mosaic, aerialBricks)
#rename raster layers
for(n in 1:nlayers(summerRLP)) {
  names(summerRLP)[n] <- layerNames[n]
}

# 3 - crop raster to extent of RLP
#-----------------------------------
border <- read_sf(file.path(envrmt$path_Landesgrenze_RLP, "Landesgrenze_RLP.shp")) #load polygon of rlp
border <- sf::st_transform(border, crs(summerRLP)) # reproject to UTM32N
borderBuffer <- sf::st_buffer(border, dist = 200) #buffer of 200m around border
#sf::write_sf(borderBuffer, file.path(envrmt$path_Landesgrenze_RLP, "border200mBuffer.shp")) #save sf object

#crop winter raster
winterRLPCropped <- raster::crop(winterRLP, borderBuffer)#crop winter raster to borders of RLP with a 200m buffer
r <- writeRaster(winterRLPCropped, file.path(envrmt$path_winter, "winterRLP.grd"), overwrite = TRUE)#save raster
hdr(r, format = "ENVI")

#crop summer raster
summerRLPCropped <- raster::crop(summerRLP, borderBuffer)#crop winter raster to borders of RLP with a 200m buffer
r <- writeRaster(summerRLPCropped, file.path(envrmt$path_summer, "summerRLP.grd"), overwrite = TRUE)#save raster
hdr(r, format = "ENVI")


