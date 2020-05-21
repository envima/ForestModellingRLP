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


veg_ind <- function(rasterStack, rgbInd = TRUE, ndvi = TRUE, ccci = TRUE, tci = TRUE, dvi = TRUE, rdi = TRUE) {

# 3.1 - rgb indices
#------------------
if (rgbInd == TRUE) {
  # rgb indices includes the following indices:  
  #VVI", "VARI", "NDTI", "RI", "SCI", "BI", "SI", "HI", "TGI", "GLI", "NGRDI",
  # "GRVI", "GLAI", "HUE", "CI", "SAT", "SHP"
  rgbIndices <- uavRst::rgb_indices(rasterStack$B04, rasterStack$B03, rasterStack$B02)
}
# 3.2 - NDVI
#-----------
#Normalized Difference NIR/Red Normalized Difference Vegetation Index, Calibrated NDVI - CDVI source: https://www.indexdatabase.de/db/i-single.php?id=58
if (ndvi == TRUE) {
  cat(":::: Normalized Difference NIR/Red Normalized Difference Vegetation Index NDVI", "\n")
  NDVI <- (rasterStack$B08-rasterStack$B04)/(rasterStack$B08+rasterStack$B04)
  names(NDVI)[1] <- "NDVI"
}
  

# 3.3 - CCCI
#-----------
#Canopy Chlorophyll Content Index source: https://www.indexdatabase.de/db/i-single.php?id=224
if (ccci == TRUE) {
  cat(":::: Canopy Chlorophyll Content Index  CCCI", "\n")
  CCCI <- ((rasterStack$B09-rasterStack$B05)/(rasterStack$B09+rasterStack$B05))/((rasterStack$B09-rasterStack$B04)/rasterStack$B09+rasterStack$B04)
  names(CCCI)[1] <- "CCCI"
  }
  
# 3.4 - TCI
#-----------
#Triangular chlorophyll index source: https://www.indexdatabase.de/db/i-single.php?id=392
if (tci == TRUE) {
  cat(":::: Triangular chlorophyll index  TCI", "\n")
  TCI <- 1.2*(rasterStack$B05 - rasterStack$B03) - 1.5*(rasterStack$B04 - rasterStack$B03) * sqrt(rasterStack$B05/rasterStack$B04)
  names(TCI)[1] <- "TCI"
  }
  
# 3.5 - DVI
#----------
#Simple Ratio NIR/RED Difference Vegetation Index, Vegetation Index Number (VIN) source: https://www.indexdatabase.de/db/i-single.php?id=12
if (dvi == TRUE) {
  cat(":::: Simple Ratio NIR/RED Difference Vegetation Index  DVI ", "\n")
  DVI <- rasterStack$B09/rasterStack$B05
  names(DVI)[1] <- "DVI"
}
  
# 3.6 - RDI
#----------
#Simple Ratio MIR/NIR Ratio Drought Index source: https://www.indexdatabase.de/db/i-single.php?id=71
if (rdi == TRUE) {
  cat(":::: Simple Ratio MIR/NIR Ratio Drought Index  RDI", "\n")
  RDI <- rasterStack$B12/rasterStack$B09
  names(RDI)[1] <- "RDI"
}

# 3.7 - stack layers
#------------------

final <- raster::stack(rgbIndices, NDVI, CCCI, TCI, DVI, RDI)
return(final)
#--------------------
}

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
