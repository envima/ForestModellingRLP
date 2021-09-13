#' @name 003_seninel_indices.R
#' @docType function
#' @description 
#' @param filepath
#' @param suffix
#' @param outPath
#' @param redEdge1
#' @param redEdge2
#' @param redEdge3
#' ...
#' @return 


sentinelIndices <- function(filePath,
                            outPath,
                            suffix = "_summer",
                            redEdge1 = "B5",
                            redEdge2 = "B6",
                            redEdge3 = "B7",
                            nir = "B8",
                            swir2 = "B11", 
                            swir3 = "B12",
                            red = "B4",
                            green = "B3", 
                            blue = "B2") {
  
  
  # load raster
  r = raster::stack(filePath)
  
  #calculate indices
  RGBIndices <- uavRst::rgb_indices(red = r[[red]], 
                                    green = r[[green]], 
                                    blue = r[[blue]])
  spectralIndices <- RStoolbox::spectralIndices(img = r, 
                                                redEdge1, 
                                                redEdge2, 
                                                redEdge3,
                                                nir, 
                                                swir1 = NULL,
                                                swir2, 
                                                swir3, 
                                                red,
                                                green, 
                                                blue)
  
  # stack all layers to one stack
  r <- raster::stack(RGBIndices, spectralIndices, r)
  
  # rename
  names(r) = paste0(names(r), suffix)
  
  
  
  #safe
  if (!is.null(outPath)) {
    r = terra::rast(r)
    terra::writeRaster(r, outPath, overwrite = TRUE)
  }
  
  return(r)
} # end of function

