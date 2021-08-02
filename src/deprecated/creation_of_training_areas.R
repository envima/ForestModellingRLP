#date: 13.04.2020
#name: creation_of_training_areas.R
#data: treeCover 2000 and lossyear 2018 source: https://earthenginepartners.appspot.com/science-2013-global-forest/download_v1.6.html
#                                       parts: 50N_000E, 60N_000E
#      polygon of RLP with buffer of 200m, source: https://opendata-esri-de.opendata.arcgis.com/datasets/esri-de-content::landesgrenze-rlp/data
#      forest managment data RLP
#output:

# 1 - load environment and libraries
#-----------------------------------
source(file.path(envimaR::alternativeEnvi(root_folder = "C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu"),
                 "src/setup_forest_modelling.R"))


# 2 - forest and non-forest training area
#----------------------------------------

# load tree cover tiles for RLP year 2000 
treeCover2000South <- raster::brick(file.path(envrmt$path_hansen, "Hansen_GFC-2018-v1.6_treecover2000_50N_000E.tif"))
treeCover2000North <- raster::brick(file.path(envrmt$path_hansen, "Hansen_GFC-2018-v1.6_treecover2000_60N_000E.tif"))

#crop treeCover to boundaries of RLP
border <- sf::read_sf(file.path(envrmt$path_Landesgrenze_RLP, "border200mBuffer.shp"))
border <- sf::st_transform(border, crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")#reproject border to crs of hansen data
treeCover2000NorthRLP <- raster::crop(treeCover2000North, border) # crop to extent of border RLP
treeCover2000SouthRLP <- raster::crop(treeCover2000South, border) # crop to extent of border RLP

#merge the cropped tiles 
treeCover2000RLP <- raster::merge(treeCover2000SouthRLP, treeCover2000NorthRLP)
rm(treeCover2000North, treeCover2000South, treeCover2000SouthRLP, treeCover2000NorthRLP)
raster::writeRaster(treeCover2000RLP, file.path(envrmt$path_hansen, "treeCover2000RLP.tif"), overwrite = TRUE)

#load and crop lossyear2018
lossYear2018South <- raster::brick(file.path(envrmt$path_hansen, "Hansen_GFC-2018-v1.6_lossyear_50N_000E.tif"))
lossYear2018North <- raster::brick(file.path(envrmt$path_hansen, "Hansen_GFC-2018-v1.6_lossyear_60N_000E.tif"))

#crop treeCover to boundaries of RLP
lossYear2018NorthRLP <- raster::crop(lossYear2018North, border)
lossYear2018SouthRLP <- raster::crop(lossYear2018South, border)

#merge the cropped tiles 
lossYear2018RLP <- raster::merge(lossYear2018SouthRLP, lossYear2018NorthRLP)
rm(lossYear2018North, lossYear2018South, lossYear2018SouthRLP, lossYear2018NorthRLP)
raster::writeRaster(lossYear2018RLP, file.path(envrmt$path_hansen, "lossYear2018RLP.tif"), overwrite = TRUE)

# 2.1 - calculate tree cover 2018
#--------------------------------------
lossYear2018RLP[lossYear2018RLP > 0] <- NA # all forest loss should be removed from treeCover
lossYear2018RLP[lossYear2018RLP == 0] <- 1 # other values should stay the same

# remove larger values and set NA values to 0
treeCover2018 <- treeCover2000RLP/lossYear2018RLP
treeCover2018[is.na(treeCover2018[])] <- 0 

writeRaster(treeCover2018, file.path(envrmt$path_hansen, "treeCover2018.tif"), overwrite = TRUE)


# 3 - training data tree species
#--------------------------------

#load forest management data
wefl_UTM_BAZ <- sf::read_sf(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_UTM_BAZ.shp"))

#select tree species with at least 80% 
wefl_UTM_BAZ <- wefl_UTM_BAZ[wefl_UTM_BAZ$proz > 80,]
sf::write_sf(wefl_UTM_BAZ, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "training_80Percent.shp")) #save 80% data

wefl_WGS84_BAZ <- sf::st_transform(wefl_UTM_BAZ, crs(treeCover2018))# change projection to proj=longlat +datum=WGS84
sf::write_sf(wefl_WGS84_BAZ, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ.shp"))

lossYear2018RLP <- raster::brick(file.path(envrmt$path_hansen, "lossYear2018RLP.tif"))
v <- raster::extract(lossYear2018RLP, wefl_WGS84_BAZ) # extract loss data for each polygon from hansen data

# 3.1 - select data with less than 5% forest loss (Hansendata)
#-------------------------------------------------------------

r <- NULL
for (i in 1:length(v)) {
  tryCatch( #use to continue for-loop if an error is caught
    
    expr = { # start code 
      
      result <- (sum(v[[i]] > 0))/(length(v[[i]])) # calculate percentage of loss per polygon
      if (result > 0.05) { # if loss is larger than 5 percent save in r
        r <- append(r, i)
      }
    },
    error = function(e){ 
      # Do this if an error is caught...
      message(paste0('Caught an error in row ', i))
      print(e)
    }
  ) # end tryCatch
  
} # end of loop

wefl_WGS84_BAZ_5Loss <- wefl_WGS84_BAZ[-c(r), ] # all polygons that have less than 5percent loss
sf::write_sf(wefl_WGS84_BAZ_5Loss, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ_5Loss.shp"))
wefl_WGS84_BAZ_5Loss <- sf::read_sf(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ_5Loss.shp"))


# 3.2 - create overview traningsdata
#-----------------------------------
trainingData <- data.frame(BAGrp = integer(),  #creation of empty data frame 
                           Phase = character(), 
                           nDatasets = integer())
BAGrp <- seq(10,90, by = 10) # tree species number
Phase <- c("Etb", "Qua", "Dim", "Rei", "Gen", "Zer") # Phase


for (b in BAGrp) {
  for (p in Phase) {
    nDatasets <- wefl_WGS84_BAZ_5Loss[wefl_WGS84_BAZ_5Loss$BAGrp == b & wefl_WGS84_BAZ_5Loss$Phase == p,] # combine each Phase with each tree species
    trainingData <- rbind(trainingData, do.call(data.frame,setNames(as.list(c(b, p, nrow(nDatasets))), names(trainingData)))) # write in dataframe
    if (nrow(nDatasets) < 100) {
      message("Baumartengruppe ", b, " hat nur ", nrow(nDatasets), " Trainingsdatens�tze in Phase ", p)
    }
  }
}

write.csv(trainingData, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "NumberTrainingAreas.csv"))


# 3.3 - class forest clearing
#------------------------------

wefl_UTM_BAZ_clearing <- wefl_UTM_BAZ[wefl_UTM_BAZ$BAGrp == 0,]
sf::write_sf(wefl_UTM_BAZ_clearing, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "clearing_UTM.shp"))
