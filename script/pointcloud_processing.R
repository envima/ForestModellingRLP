#date: 04.06.2020
#name: pointcloud_processing.R
#data:
#output:
#-------------------------------------

# 1 - load environment and libraries
#-------------------------------------

source(file.path(envimaR::alternativeEnvi(root_folder = "C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu"),
                 "src/setup_forest_modelling.R"))

library(RSDB)
library(sp)

#-------------------------------------

# 2 - remote sensing database
#-------------------------------------

# set account
userpwd <- "" # use this account (if not loaded from file)
#fileName <- "~/.remote_sensing_userpwd.txt" # optional file in home directory content: user:password
#userpwd <- readChar(fileName, file.info(fileName)$size) # optional read account from file

# open remote sensing database
#remotesensing <- RemoteSensing$new("http://localhost:8081", userpwd) # local
remotesensing <- RemoteSensing$new("http://192.168.191.183:8081", userpwd) # remote server

# get pointcloud names
remotesensing$plointclouds

# open pointcloud
pointcloud <- remotesensing$pointcloud("rheinland_pfalz")

# get description
pointcloud$description

# get projection as geo code (e.g. EPSG)
pointcloud$geocode

# get projection as proj4
pointcloud$proj4

# get extent
pointcloud$extent

#------------------------------------------

# 3 - ROIs
#----------------

etb_utm_32 <- rgdal::readOGR(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "etb_utm_32.shp"))
qua_dim_rei_utm_32 <- rgdal::readOGR(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "qua_dim_rei_utm_32.shp"))

#------------------------

# 4 - calculate one indice
#------------------------
etb_utm_32@data$BE_H_P100 <- NA

# mean chm Etablierung for each polygon
for (i in 1:length(etb_utm_32)){
  p <- Polygon(coords=etb_utm_32@polygons[[i]]@Polygons[[1]]@coords)# polygon with extent of ROIs
  result <- pointcloud$indices(p, "BE_H_P100") # calculate index at polygon
  etb_utm_32@data$BE_H_P100[[i]] <- result$BE_H_P100 # write
}

rgdal::writeOGR(etb_utm_32, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "etb_utm_32.shp"),layer = "etb_utm_32.shp", overwrite_layer = TRUE, driver = "ESRI Shapefile") 
etb_chm_mean <- mean(etb_utm_32@data$chm_mean) # mean canopy height Etablierung


# mean chm Qualifizierung, Dimensionierung, Reife
qua_dim_rei_utm_32@data$chm_mean <- NA # create new column for chm_mean

for (i in 1:length(qua_dim_rei_utm_32)){
  p <- Polygon(coords=qua_dim_rei_utm_32@polygons[[i]]@Polygons[[1]]@coords)# polygon with extent of ROIs
  result <- pointcloud$indices(p, "chm_height_mean") # calculate index at polygon
  if (length(result$chm_height_mean != 0)) {
    qua_dim_rei_utm_32@data$chm_mean[[i]] <- result$chm_height_mean # write mean chm
  } else {
    qua_dim_rei_utm_32@data$chm_mean[[i]] <- NA
  }
  
}


rgdal::writeOGR(qua_dim_rei_utm_32, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "qua_dim_rei_utm_32.shp"),layer = "qua_dim_rei_utm_32.shp", overwrite_layer = TRUE, driver = "ESRI Shapefile") 
qua_dim_rei_chm_mean <- mean(qua_dim_rei_utm_32@data$chm_mean) # mean canopy height Etablierung


#-----------------------------------------



# 4.1 - calculate all indices for area of polygon
#--------------------------------------------------

#create empty data frame
ind <- data.frame()

# indices for each polygon (Etablierung)
for (i in 1:length(etb_utm_32)){
  p <- Polygon(coords=etb_utm_32@polygons[[i]]@Polygons[[1]]@coords)# polygon with extent of ROIs
  df <- pointcloud$indices(list(p1=p), pointcloud$index_list$name) # calculate all indices for polygon
  df$name[[1]] <- etb_utm_32@data$FAT__ID[[i]] # rename to FAT_ID
  ind <- rbind(ind, df) 
}

#write as csv
write.csv(ind, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "etb_ind.csv")) 

