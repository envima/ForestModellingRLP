#' @name 007_modelling.R
#' @docType function
#' @description 
#' @param predResp data frame from balancing the data
#' @param responseType
#' @param responseColName
#' @param predcitorsColNo
#' @param spacevar




modelling <- function(predResp, 
                      responseType = "meta_classes_main_trees", 
                      responseColName = "BAGRu",
                      predictorsColNo = 3:13,
                      spacevar = "FAT__ID",
                      bot,
                      alert_chats)
{
  
  
  a <- Sys.info()
  for(i in 1:length(alert_chats)){bot$send_message(chat_id = alert_chats[i],text = paste0("Initiated calculations for response type ",responseType,
                                                                                          ". Calculating on computer ", a[names(a)=="nodename"],
                                                                                           " by user ", a[names(a)=="user"], 
                                                                                          ". I will alert you when calculations are finished."
  ))
  }
  
  
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
  predictors <- predResp %>% ungroup() %>% dplyr::select(dplyr::all_of(predictorsColNo))
  response <- factor(predResp %>% pull(all_of(responseColName)))
  
  
  #cl <- makeCluster(ncores)
  #registerDoParallel(cl)
  #set.seed(10)
  
  
  ffsmodel <- par_ffs(predictors,
                  response, 
                  metric="Kappa", 
                  method="rf",
                  trControl=ctrl, 
                  importance = TRUE ,
                  tuneLength = 1, 
                  ntree = 50)
  
  
  
  #stopCluster(cl)
  
  for(i in 1:length(alert_chats)){bot$send_message(chat_id = alert_chats[i],
                                                   text = paste0("Finished calculations for response type ",responseType,
                                                                 ". On computer ", a[names(a)=="nodename"], 
                                                                 ", Initiated by user ", a[names(a)=="user"], 
                                                                 " The accuracy of the model is: ", 
                                                                 round(ffsmodel$results$Accuracy, 4)*100
                                                   )
  )
  }
  
  return(ffsmodel)
} # end function