# name: prediction_diverse.R
# date: 17 09 2020
# data: raster stacks with selected variables, models
# output: raster stacks with prediction for classes: diverse trees, beech, doug, oak,
#                                                    spruce, pine, larch, lbk, lbl


# 1 - set up
#------------------------------

require(raster)
require(CAST)

 
# 2 - predict the diverse tree classes ####
#------------------------------------------

model <- load("models/meta_classes_diverse_ffs.RData")
selvar <- raster::stack("data/stacked_selected_vars/diverse_classes.grd")


start_time <- Sys.time()
prediction <- predict(selvar, ffsmodel)
end_time <- Sys.time()

end_time - start_time


r <- writeRaster(prediction, "prediction/diverse_trees_pred.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(prediction, "prediction/diverse_trees_pred.RDS")


# 3 - predict the successional phases ####
#-----------------------------------------

predClass <- 0

for (i in c("beech", "doug", "oak", "spruce", "pine", "larch", "lbk", "lbl")) { # beginning for loop
  
  mask <- prediction
  predClass <- predClass + 1
  mask[mask != predClass] <- NA
  model <- readRDS(paste0("models/quality_", i, "_ffs.RDS"))
  selvar <- raster::stack(paste0("data/stacked_selected_vars/", i, ".grd"))
  selvar <- mask(selvar, mask)
  
  start_time <- Sys.time()
  pred <- predict(selvar, model)
  end_time <- Sys.time()
  
  print(paste("finished prediction ", i, "in ", end_time - start_time, " minutes"))
  
  r <- writeRaster(pred, paste0("prediction/", i, "_diverse.grd"), overwrite = TRUE) #save raster
  hdr(r, format = "ENVI")
  saveRDS(pred, paste0("prediction/", i, "_diverse.RDS"))
  
} # end for loop




