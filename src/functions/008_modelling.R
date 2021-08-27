#' @name 007_modelling.R
#' @docType function
#' @description 
#' @param predResp data frame from baalncing the data
#' @param responseType
#' @param responseColName
#' @param predcitorsColNo
#' @param spacevar
#' @param ncores



modelling <- function(predResp, 
                      responseType = "meta_classes_main_trees", 
                      responseColName = "BAGRu",
                      predictorsColNo = 3:13,
                      spacevar = "FAT__ID",
                      ncores = 10)
{

  predResp <- na.omit(predResp)
  ### Initialise Leave-Location out cv
  ## Main difference in the modelling strategy: we combine multiple location in the folds
  # sample a ten fold cv stratified after the main tree species (BAGRu)
  # spacevar = "FAT__ID" divides the polygon IDs into different folds
  # CAST version 0.4.2

  indices <- CreateSpacetimeFolds(predResp, 
                                  spacevar, 
                                  k=10, 
                                  class = responseColName)



  ### Initialize Modelling

  set.seed(10)
  ctrl <- trainControl(method="cv",
                      index = indices$index,
                      savePredictions=TRUE )



  # no model tuning
  tgrid <- expand.grid(.mtry = 2,
                      .splitrule = "gini",
                      .min.node.size = 1)



  #run ffs model with Leave Location out CV
  # we use randomForest now, ranger defaults to num.threads = number of CPUs available
  # we don't want to mess with double parallel
  predictors <- predResp %>% select(all_of(predictorsColNo))
  response <- factor(predResp %>% pull(all_of(responseColName)))


  cl <- makeCluster(ncores)
  registerDoParallel(cl)
  set.seed(10)


  ffsmodel <- ffs(predictors,
                  response, 
                  metric="Kappa", 
                  method="rf",
                  trControl=ctrl, 
                  importance = TRUE ,
                  tuneLength = 1, 
                  ntree = 50)

  return(ffsmodel)

  stopCluster(cl)
} # end function