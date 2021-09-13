#' @name 008_select_variables.R
#' @docType 
#' @description 
#' @param lstModels
#' @param predictors


select_variables <- function(lstModels, predictors) {

  for (i in lstModels) {
    mod = readRDS(file.path(envrmt$models, i))
    selVars = mod$selectedvars
  
    # choose layers with selected variables
    r = terra::subset(predictors, selVars)
    # safe raster stack
    fileName = gsub("quality_|species_|_ffs.RDS", "",i)
    terra::writeRaster(r, file.path(envrmt$selected_variables, paste0(fileName, ".tif")))
  
  } #end for loop
  
} # end function
