#' @name 005_prep_forest_inventory.R
#' @docType function
#' @description preparation of Forest inventory data by filtering for species purity and forestLoss
#' @param FID forest inventory dataframe
#' @param forestMask Hansen forest loss data of 2018
#' @param identicalCrs boolean; default = FALSE; crs(sf object) is set to crs (raster)
#' @param purityCol = "proz"
#' @param purity default = 80
#' @return filtered forest inventory data as sf object


prep_forest_inventory <- function(FID, forestMask, identicalCrs = FALSE, treeSpeciesPurity = 80){

  # if crs of FID and forestLoss are different change crs of FID to crs(forestLoss)
  if (identicalCrs == FALSE) {
    FID <- sf::st_transform(FID, crs(forestLoss))# change projection to proj=longlat +datum=WGS84
  }

  # filter for at least x percent tree species groups purity
  FID = FID %>% filter((!!sym(purityCol)) > purity)

  # extract forest loss data for each polygon
  v <- terra::extract(forestMask, vect(FID)) # extract loss data for each polygon from hansen data
  new = 
  
  # select data with less than 5% forest loss
  r <- NULL
  for (i in 1:length(unique(v$ID))) {
    
        test = v[v$ID == i,]
        result <- (nrow(na.omit(test))/nrow(test)) # calculate percentage of loss per polygon
        if (result > 0.05) { # if loss is larger than 5 percent save in r
          r <- append(r, i)
  } # end of loop

  # select polygons that have less than 5 percent forest loss, drop everything else
  FID <- FID[-c(r), ]

  return(FID)
} # end function
  