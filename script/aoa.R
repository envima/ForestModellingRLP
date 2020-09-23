# name: aoa.R
# date: 21 09 2020
# data: models, pred stacks
# output: area of applicability - https://arxiv.org/abs/2005.07939


# 1 - set up
#------------------------------

require(raster)
require(CAST)

# 2 - aoa diverse trees ###
#-------------------------------------

model <- load("models/meta_classes_diverse_ffs.RData")
diverse <- raster::stack("data/stacked_selected_vars/diverse_classes.grd")

start_time <- Sys.time()
aoa_diverse <- CAST::aoa(
                      newdata = diverse,
                      model = ffsmodel,
                      train = NULL,
                      weight = NA,
                      variables = "all",
                      thres = 0.95, # numeric vector of probability of DI in training data, with values in [0,1]?
                      folds = NULL
)
end_time <- Sys.time()
end_time - start_time


r <- writeRaster(aoa_diverse, "aoa/aoa_diverse.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(prediction, "aoa/aoa_diverse.RDS")


# 2.1 - aoa of diverse successional phases
#-----------------------------------------
predClass <- 0

for (i in c("beech", "doug", "oak", "spruce", "pine", "larch", "lbk", "lbl")) { # beginning for loop
  
  mask <- raster::stack("prediction/diverse_trees_pred.grd")
  predClass <- predClass + 1
  mask[mask != predClass] <- NA
  model <- readRDS(paste0("models/quality_", i, "_ffs.RDS"))
  selvar <- raster::stack(paste0("data/stacked_selected_vars/", i, ".grd"))
  selvar <- mask(selvar, mask)
  rm(mask)
  
  start_time <- Sys.time()
  
  aoa <- CAST::aoa(
                  newdata = selvar,
                  model = model,
                  train = NULL,
                  weight = NA,
                  variables = "all",
                  thres = 0.95, # numeric vector of probability of DI in training data, with values in [0,1]?
                  folds = NULL)
    
  
  end_time <- Sys.time()
  
  cat(paste("finished aoa ", i, "in ", end_time - start_time, " minutes"))
  
  r <- writeRaster(aoa, paste0("aoa/aoa_", i, "_diverse.grd"), overwrite = TRUE) #save raster
  hdr(r, format = "ENVI")
  saveRDS(pred, paste0("aoa/aoa_", i, "_diverse.RDS"))
  
} # end for loop





