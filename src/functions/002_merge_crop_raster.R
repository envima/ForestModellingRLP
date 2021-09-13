#' @name 002_merge_crop_raster.R
#' @doctype function
#' @description
#' @param listOfFiles
#' @param setNAValues = 
#' @return 



merge_crop_raster <- function(listOfFiles, setNAValues = cbind(-Inf, 0.00001, NA)) {
  
  
  
  aerialBricks <- list()
  # if background values are != NA you can change them to the value you want
  if (!is.null(setNAValues)) {
    for(i in listOfFiles){
      r <- terra::rast(i)
      r = terra::classify(r, setNAValues, right=FALSE)
      terra::writeRaster(r, i, overwrite = TRUE)
      rm(r)
      cat(paste("Finished reclassify background values to NA.\n"))
    }
  }
  # create list with rast objects
  for(i in listOfFiles){
    r <- terra::rast(i)
    aerialBricks <- c(aerialBricks, r)
  }
  cat(paste("start merging raster tiles.\n"))
  
  # if you have many SpatRasters make a SpatRasterCollection from a list
  rscr = terra::src(aerialBricks)
  m <- terra::mosaic(rscr, fun = "mean")
  
  return(m)
} # end of function
