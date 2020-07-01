#date: 24.04.2020
#name: indices_RLP.R
#data: raster data of RLP
#output: raster stack with indices

#----------------------------------------------------------

# 1 - load libraries and working Environment
#--------------------------------------------
source(file.path(envimaR::alternativeEnvi(root_folder = "C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu"),
                 "src/setup_forest_modelling.R"))

# 2 - load data
#---------------

#summer and winter sentinel raster stack
winterRLP <- raster::brick(file.path(envrmt$path_winter, "winterRLP.grd"))
summerRLP <- raster::brick(file.path(envrmt$path_summer, "summerRLP.grd"))

# 3 - create raster stack with vegetation indices
#------------------------------------------------


# 3.1 - rgb indices
#-------------------
# rgb indices includes the following indices:  
#VVI", "VARI", "NDTI", "RI", "SCI", "BI", "SI", "HI", "TGI", "GLI", "NGRDI",
# "GRVI", "GLAI", "HUE", "CI", "SAT", "SHP"
rgbIndices <- uavRst::rgb_indices(rasterStack$B04, rasterStack$B03, rasterStack$B02)

  
RStoolbox::spectralIndices(winterRLP, redEdge1 = "B05", redEdge2 = "B06", redEdge3 = "B07",
                           nir = "B8A", swir1 = "B09", swir2 = "B11", swir3 = "B12", red = "B04",
                           green = "B03", blue = "B02")
  
  
  
  
  
  
# 4 - safe vegetation indices stack
#----------------------------------

IndSummerRLP <- veg_ind(rasterStack = summerRLP)
raster <-raster::writeRaster(IndSummerRLP, file.path(envrmt$path_summer, "indicesSummerRLP.grd"), format="raster", overwrite = TRUE)
hdr(raster, format = "ENVI")
saveRDS(IndSummerRLP, file.path(envrmt$path_summer, "indicesSummerRLP.RDS"))

IndWinterRLP <- veg_ind(rasterStack = winterRLP)
raster <-raster::writeRaster(IndWinterRLP, file.path(envrmt$path_winter, "indicesWinterRLP.grd"), format="raster", overwrite = TRUE)
hdr(raster, format = "ENVI")
saveRDS(IndWinterRLP, file.path(envrmt$path_winter, "indicesWinterRLP.RDS"))
