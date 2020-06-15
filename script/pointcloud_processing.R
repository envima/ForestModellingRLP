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
#userpwd <-  "user:password" # use this account (if not loaded from file)
fileName <- file.path(envrmt$path_src, "remote_sensing_userpwd.txt") # optional file in home directory content: user:password
userpwd <- readChar(fileName, file.info(fileName)$size) # optional read account from file

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
# polygons as Spatial Polygon Data Frame
etb <- rgdal::readOGR(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "etablierung_ETRS89_UTM_32N.shp"))
qua_dim_rei <- rgdal::readOGR(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "qua_dim_rei_utm_32.shp"))



#------------------------


# 4 - calculate all indices for ROI
#-----------------------------------

source(file.path(envrmt$path_script, "LIDAR_Indices_function.R"))
ind <- LIDAR_Indices(spdf = qua_dim_rei, ID_Col = 1)

#safe as csv
write.csv(ind, file.path(envrmt$path_indices, "qua_dim_rei_ind.csv"))
 
 
# 5 - plot data
#--------------

# read indices
qua_dim_rei_ind <- read.csv(file.path(envrmt$path_indices, "qua_dim_rei_ind.csv"))
etb_ind <- read.csv(file.path(envrmt$path_indices, "etb_ind.csv"))
# load shapefiles
shape <- sf::read_sf(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ_5Loss.shp"))

#bind indices to get a dataframe with Etalierung, Reife, Dimensionierung und Qualifikation
ind <- rbind(qua_dim_rei_ind, etb_ind)
rm(qua_dim_rei_ind, etb_ind) #clean

#merge indices with polygon
data <- merge(ind, shape, by.x = "name", by.y = "FAT__ID")
 
# Library
library(ggplot2)
 
 
data <- data.frame(name = data$Phase,
                    value = data$BE_H_MEDIAN
)
#sort phase
data$name <- factor(data$name,levels = c("Etb", "Qua", "Dim", "Rei"))
 
data <- na.omit(data)
# violin chart
p <- ggplot(data, aes(x=name, y=value, fill=name)) + # fill=name allow to automatically dedicate a color for each group
   geom_violin() + 
   labs(y="Median Canopy Height (m)", x = "Phase")
 
p
 
 


