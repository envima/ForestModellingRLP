#' @name 005_prep_forest_inventory.R
#' @docType function
#' @description preparation of Forest inventory data by filtering for species purity and forestLoss
#' @param FID forest inventory dataframe
#' @param forestMask Hansen forest loss data of 2018
#' @param identicalCrs boolean; default = FALSE; crs(sf object) is set to crs (raster)
#' @param purityCol = "proz"
#' @param purity default = 80
#' @param idCol = "FAT__ID"
#' @return filtered forest inventory data as sf object


prep_forest_inventory <- function(FID, forestMask, identicalCrs = FALSE, purity = 80, purityCol = "proz", idCol = "FAT__ID"){
  
  # if crs of FID and forestMask are different change crs of FID to crs(forestLoss)
  if (identicalCrs == FALSE) {
    FID <- sf::st_transform(FID, crs(forestMask))# change projection to proj=longlat +datum=WGS84
  }
  
  # filter for at least x percent tree species groups purity
  FID = FID %>% filter((!!sym(purityCol)) > purity)
  
  # extract forest loss data for each polygon
  v <- terra::extract(forestMask, vect(FID)) # extract loss data for each polygon from hansen data
  df = data.frame(id = FID %>% pull(all_of(idCol)), 
                  ID = unique(v$ID))
  df = merge(v, df, by.x = "ID", by.y = "ID")
  df$ID <- NULL
  
  # select data with less than 5% forest loss
  r <- NULL
  for (i in unique(df$id)) {
    pol = df[df$id == i,]
    result <- 1-(nrow(na.omit(pol))/nrow(pol)) # calculate percentage of loss per polygon
    if (result > 0.05) { # if loss is larger than 5 percent save in r
      r <- append(r, i)
      print(paste("polygon", i, "has more than 5 % forest loss"))
    } 
  } # end of for loop
  
  
  
  `%not_in%` <- purrr::negate(`%in%`)
  # select polygons that have less than 5 percent forest loss, drop everything else
  FID2 <- FID %>% filter((!!sym(idCol)) %not_in% r)
  
  return(FID)
} # end function
