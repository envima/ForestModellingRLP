#' @name 002_merge_crop_raster.R
#' @doctype function
#' @description
#' @param listOfFiles
#' @param setNAValues = 
#' @return 



merge_crop_raster <- function(listOfFiles) {
  
  
  
  aerialBricks <- list()
  
  # create list with rast objects
  for(i in listOfFiles){
    r <- raster::stack(i)
    aerialBricks <- c(aerialBricks, r)
  }
  cat(paste("start merging raster tiles.\n"))
  
  # if you have many SpatRasters make a SpatRasterCollection from a list
 aerialBricks$fun = "max"
  # rscr = terra::src(aerialBricks)
  #rscr = raster::stack(aerialBricks)
  m = do.call(raster::mosaic, aerialBricks)
  #m <- raster::mosaic(rscr)
  names(sentinel) <- c("B01",  "B02"  ,"B03",  "B04",  "B05",  "B06"  ,"B07",  "B08", "B09"  ,"B11", "B12")
                     
  return(m)
} # end of function
