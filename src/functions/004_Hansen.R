#' @name 004_Hansen.R
#' @docType function
#' @description 
#' @param hansen
#' @param changeCRS = "epsg:25832"
#' @return forest



prep_hansen <- function(hansen, changeCRS = "epsg:25832"){
  
  treeCover = hansen[[1]]
  loss = hansen[[2]]
  gain = hansen[[3]]
  
  # all forest loss should be removed from treeCover
  loss[loss > 0] <- NA 
  
  treeCover[treeCover > 0] <- 1
  treeCover[treeCover == 0] <- NA
  
  treeCoverLoss = terra::mask(treeCover, loss)
  
  #1 (gain) or 0 (no gain).
  forest = terra::mask(treeCoverLoss, gain, 
                       maskvalues = 1,
                       updatevalue = 1)
  
  if (!is.null(changeCRS)) {
    forest = terra::project(forest, changeCRS)
  }
  return (forest)
  
} # end of function