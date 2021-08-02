#' @name 001_prep_sentinel.R
#' @docType function
#' @description 
#' @param folderNames
#' @param fileNames
#' @param resolution 
#' @param outputPath
#' @return Sentinel Scenes at the same resolution each tile stacked



prepSentinel <- function(resolution = 10, folderNames, fileNames, outputPath) {
   

n = 0
for (i in folderNames){
   
   n = n+1
   if (resolution == 20) {
      R20 <- terra::rast(list.files(paste0(i, "/IMG_DATA/R20m"), pattern = glob2rx("*.jp2"), full.names = TRUE))
   } else {
      R20 <- terra::rast(list.files(paste0(i, "/IMG_DATA/R20m"), pattern = glob2rx("*.jp2"), full.names = TRUE))
      if (resolution == 10) {
         R20 <- terra::disaggregate(R20, 2) }
      else{
         R20 <- terra::aggregate(R20, 3)
      }
   }
   
   
   if (resolution == 10) {
      R10 <- terra::rast(list.files(paste0(i, "/IMG_DATA/R10m"), pattern = glob2rx("*.jp2"), full.names = TRUE))
      
   } else {
      R10 <- terra::rast(list.files(paste0(i, "/IMG_DATA/R10m"), pattern = glob2rx("*.jp2"), full.names = TRUE))
      if (resolution == 60) {
         R10 <- terra::aggregate(R10, 6) }
      else{
         R10 <- terra::aggregate(R10, 2)
      }
   }
   
   
   if (resolution == 60) {
      R60 <-  terra::rast(list.files(paste0(i, "/IMG_DATA/R60m"), pattern = glob2rx("*.jp2"), full.names = TRUE))
      
   } else {
      R60 <-  terra::rast(list.files(paste0(i, "/IMG_DATA/R60m"), pattern = glob2rx("*.jp2"), full.names = TRUE))
      if (resolution == 10) {
         R60 <- terra::disaggregate(R60, 6) }
      else{
         R60 <- terra::disaggregate(R60, 3)
      }
   }
   
   cat(paste("changed resolution for tile ", fileNames[n], "\n"))
   #Stack all layers
   r <- terra::rast(list(R60, R20, R10))
   
   # rename layers
   layerNames <- gsub("_20m|_10m|_60m", "", names(r))
   layerNames <- substr(layerNames, nchar(layerNames)-3+1, nchar(layerNames))
   names(r) <- layerNames

   #safe as raster
   terra::writeRaster(r, file.path(outputPath, paste0(fileNames[n], ".grd")), overwrite = TRUE)
   
}
   
   
}


