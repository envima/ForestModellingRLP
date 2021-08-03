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
                            redEdge1 = "B05",
                            redEdge2 = "B06",
                            redEdge3 = "B07",
                            nir = "B08",
                            swir2 = "B11", 
                            swir3 = "B12",
                            red = "B04",
                            green = "B03", 
                            blue = "B02") {


# load raster
r = terra::rast(filePath)

#calculate indices
RGBIndices <- uavRst::rgb_indices(red = terra::subset(r, red), 
                                  green = terra::subset(r, green), 
                                  blue = terra::subset(r, blue))
spectralIndices <- RStoolbox::spectralIndices(winterRLP, 
                                              redEdge1, 
                                              redEdge2, 
                                              redEdge3,
                                              nir, 
                                              swir2, 
                                              swir3, 
                                              red,
                                              green, 
                                              blue)

# stack all layers to one stack
r <- terra::rast(list(RGBIndices, spectralIndices, r))

# rename
names(r) = paste0(names(r), suffix)

return(r)

#safe
terra::writeRaster(r, outputPath, format="raster", overwrite = TRUE)

} # end of function

