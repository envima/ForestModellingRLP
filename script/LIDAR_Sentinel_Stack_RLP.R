#date: 14.07.2020
#name: LIDAR_Sentinel_Stack_RLP.R
#data:                                               
#output: 
#----------------------------------------------------------

# 1 - load libraries and working Environment
#--------------------------------------------
source(file.path(envimaR::alternativeEnvi(root_folder = "C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu"),
                 "src/setup_forest_modelling.R"))



# 2 - rasterDB
#------------------------

library(RSDB)

# set account
#userpwd <- "user:password" # use this account (if not loaded from file)
fileName <- file.path(envrmt$path_src, "remote_sensing_userpwd.txt") # optional file in home directory content: user:password
userpwd <- readChar(fileName, file.info(fileName)$size) # optional read account from file

# open remote sensing database
#remotesensing <- RemoteSensing$new("http://localhost:8081", userpwd) # local
remotesensing <- RemoteSensing$new("http://192.168.191.183:8081", userpwd) # remote server
#remotesensing <- RemoteSensing$new("http://137.248.191.215:8081", userpwd) # remote server

# get names of RasterDBs
remotesensing$rasterdbs

# get one rasterdb
rasterdb <- remotesensing$rasterdb("RLP_forest_mask_20m_i4")

ext <- rasterdb$extent

# get RasterStack of all bands at ext
LIDARIndices <- rasterdb$raster(ext)


# 3 - load sentinel data
#-------------------------

summerRLP <- 
winterRLP <- 
summerIndices <- 
winterIndices <- 



# 4 - stack all 
#----------------------------


RLPStack <- raster::stack(LIDARIndices, summerRLP, winterRLP, summerIndices, winterIndices)








