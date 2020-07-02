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

#winter
winterRGB <- uavRst::rgb_indices(red = winterRLP$B04, green = winterRLP$B03, blue = winterRLP$B02)
winterSpectral <- RStoolbox::spectralIndices(winterRLP, redEdge1 = "B05", redEdge2 = "B06", redEdge3 = "B07",
                           nir = "B08", swir2 = "B11", swir3 = "B12", red = "B04",
                           green = "B03", blue = "B02")
winterInd <- raster::stack(winterRGB, winterSpectral) 
 
#summer
summerRGB <- uavRst::rgb_indices(red = summerRLP$B04, green = summerRLP$B03, blue = summerRLP$B02)
summerSpectral <- RStoolbox::spectralIndices(summerRLP, redEdge1 = "B05", redEdge2 = "B06", redEdge3 = "B07",
                                        nir = "B08", swir2 = "B11", swir3 = "B12", red = "B04",
                                        green = "B03", blue = "B02")
summerInd <- raster::stack(summerRGB, summerSpectral) 

  
  
  
# 4 - safe vegetation indices stack
#----------------------------------


raster <-raster::writeRaster(summerInd, file.path(envrmt$path_summer, "indicesSummerRLP.grd"), format="raster", overwrite = TRUE)
hdr(raster, format = "ENVI")

raster <-raster::writeRaster(winterInd, file.path(envrmt$path_winter, "indicesWinterRLP.grd"), format="raster", overwrite = TRUE)
hdr(raster, format = "ENVI")
