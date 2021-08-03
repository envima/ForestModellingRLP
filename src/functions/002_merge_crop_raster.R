#' @name 002_merge_crop_raster.R
#' @doctype function
#' @description
#' @param listOfFiles
#' @param border
#' @param changeBorderCrs
#' @param buffer
#' @return 



merge_crop_raster <- function(listOfFiles, border, changeBorderCrs = TRUE, buffer = 200) {
 
   # change crs to crs of raster
  if (changeBorderCrs == TRUE) {
    border <- sf::st_transform(border, crs(terra::rast(listOfFiles[1]))) # reproject to first raster in listOfFiles
  }
  # add a buffer around the border
 if (buffer != 0) {
    borderBuffer <- sf::st_buffer(border, dist = buffer) #buffer of 200m around border
  }
  
  #merge all tiles
  aerialBricks <- list()
  for(i in listOfFiles){
    r <- terra::rast(i)
    r<- terra::crop(r, border)
    cat(paste("cropped raster ", i, "\n"))
    aerialBricks <- c(aerialBricks, r)
  }
  cat(paste("start merging raster tiles.\n"))

  
  # if you have many SpatRasters make a SpatRasterCollection from a lis
  rsrc <- terra::src(aerialBricks)
  m <- terra::mosaic(rsrc)
  
  return(m)
} # end of function
