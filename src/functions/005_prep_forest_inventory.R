#' @name 005_prep_forest_inventory.R
#' @docType function
#' @description preparation of Forest inventory data by filtering for species purity and forestLoss
#' @param FID forest inventory dataframe
#' @param forestLoss Hansen forest loss data of 2018
#' @param identicalCrs boolean; default = FALSE; crs(sf object) is set to crs (raster)
#' @param treeSpeciesPurity default = 80
#' @return filtered forest inventory data as sf object


prep_forest_inventory <- function(FID, forestLoss, identicalCrs = FALSE, treeSpeciesPurity = 80){

  # if crs of FID and forestLoss are different change crs of FID to crs(forestLoss)
  if (identicalCrs == FALSE) {
    FID <- sf::st_transform(FID, crs(forestLoss))# change projection to proj=longlat +datum=WGS84
  }

  # filter for at least x percent tree species groups purity
  FID = FID %>% filter(proz > treeSpeciesPurity)

  # extract forest loss data for each polygon
  v <- terra::extract(forestLoss, vect(FID)) # extract loss data for each polygon from hansen data

  # select data with less than 5% forest loss
  r <- NULL
  for (i in 1:length(v)) {
    tryCatch( #use to continue for-loop if an error is caught
    
      expr = { # start code 
      
        result <- (sum(v[[i]] > 0))/(length(v[[i]])) # calculate percentage of loss per polygon
        if (result > 0.05) { # if loss is larger than 5 percent save in r
          r <- append(r, i)
        }
      },
      error = function(e){ 
        # Do this if an error is caught...
        message(paste0('Caught an error in row ', i))
        print(e)
      }
    ) # end tryCatch
  
  } # end of loop

  # select polygons that have less than 5 percent forest loss, drop everything else
  FID <- FID[-c(r), ]

  return(FID)
} # end function