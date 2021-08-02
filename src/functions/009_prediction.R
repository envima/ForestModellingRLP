#' @name 008_prediction.R
#' @docType function
#' @description
#' @param 
#' 

# input 
#-------------------------

fileNameSpecies = "main"

#list with quality models
lstQuality <-list.files(envrmt$models, pattern="quality", full.names = TRUE)
lstSpecies <-list.files(envrmt$models, pattern=c("main", "diverse"), full.names = TRUE)

#folderModels = 
#folderPredictions = 


#!!!!!!!!!!!!!!!!
  
# 1 - prediction main/diverse model
#-------------------------------

function(lstSpecies, lstQuality) {



  for (species in lstSpecies)  {
    mod <- readRDS(species)
    selvar <- raster::stack(envrmt$, fileNameSpecies, ".grd")
    
    #prediction for species model
    start_time <- Sys.time()
    prediction <- terra::predict(selvar, mod)
    end_time <- Sys.time()
    cat("predicted ")
    end_time - start_time


if (dir.exists("D:/forest_modelling/ForestModellingRLP/data/prediction")) {

  r <- writeRaster(prediction, "prediction/diverse_trees_pred.grd", overwrite = TRUE) #save raster
  hdr(r, format = "ENVI")
  saveRDS(prediction, "prediction/diverse_trees_pred.RDS") } else
  
  {dir.create("D:/forest_modelling/ForestModellingRLP/data/prediction")
    cat("Create new folder 'prediction' in data folder.\n")
    r <- writeRaster(prediction, "prediction/diverse_trees_pred.grd", overwrite = TRUE) #save raster
    hdr(r, format = "ENVI")
    saveRDS(prediction, "prediction/diverse_trees_pred.RDS") }
      



# 3 - predict the successional phases ####
#-----------------------------------------

class = levels(prediction)[[1]]

predClass <- 0

for (i in dat_lst) { # beginning for loop
  
  response_type <- gsub(".RDS|quality_|_ffs", "", i)
  
  mask <- prediction
  predClass <- as.integer(class %>% filter(value == response_type) %>% select(ID))
  mask[mask != predClass] <- NA
  
  #!!!!!!!!!!!!
  model <- readRDS(i)
  selvar <- raster::stack(paste0("data/stacked_selected_vars/", response_type, ".grd"))
  #!!!!!!!!!!!!!!!!!!!!!
  selvar <- mask(selvar, mask)
  
  start_time <- Sys.time()
  pred <- predict(selvar, model)
  end_time <- Sys.time()
  
  print(paste("finished prediction ", response_type, "in ", end_time - start_time, " minutes"))
  
  r <- writeRaster(pred, paste0("prediction/", response_type, "_diverse.grd"), overwrite = TRUE) #save raster
  hdr(r, format = "ENVI")
  saveRDS(pred, paste0("prediction/", response_type, "_diverse.RDS"))
  
} # end for loop


} # end of function


