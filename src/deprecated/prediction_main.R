# Date: 10 09 2020
# name:
#--------------------------

library(raster)


model <- readRDS("models/meta_classes_main_trees_ffs.RDS")
selvar <- raster::stack("data/stacked_selected_vars/main_trees.grd")

ext <- extent(414500, 416000, 5471560, 5472000)
test10 <- crop(selvar, ext)


############################################

# predict the main tree classes ####

start_time <- Sys.time()
prediction <- predict(selvar, model)
end_time <- Sys.time()

end_time - start_time


r <- writeRaster(prediction, "prediction/main_trees_pred.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(prediction, "prediction/main_trees_pred.RDS")


# predict the successional phases ####

# Beech #### 
mask <- prediction
mask@data@values[mask@data@values!=1] <- NA
model <- readRDS("models/quality_beech_ffs.RDS")
selvar <- raster::stack("data/stacked_selected_vars/beech.grd")
selvar <- mask(selvar, mask)

start_time <- Sys.time()
pred <- predict(selvar, model)
end_time <- Sys.time()

end_time - start_time

r <- writeRaster(pred, "prediction/beech_main.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(pred, "prediction/beech_main.RDS")

# Oak #### 
mask <- prediction
mask@data@values[mask@data@values!=3] <- NA

model <- readRDS("models/quality_oak_ffs.RDS")
selvar <- raster::stack("data/stacked_selected_vars/oak.grd")
selvar <- mask(selvar, mask)

start_time <- Sys.time()
pred <- predict(selvar, model)
end_time <- Sys.time()

end_time - start_time

r <- writeRaster(pred, "prediction/oak_main.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(pred, "prediction/oak_main.RDS")

# Spruce #### 
mask <- prediction
mask@data@values[mask@data@values!=4] <- NA

model <- readRDS("models/quality_spruce_ffs.RDS")
selvar <- raster::stack("data/stacked_selected_vars/spruce.grd")
selvar <- mask(selvar, mask)

start_time <- Sys.time()
pred <- predict(selvar, model)
end_time <- Sys.time()
end_time - start_time

r <- writeRaster(pred, "prediction/spruce_main.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(pred, "prediction/spruce_main.RDS")

# Douglasie #### 
mask <- prediction
mask@data@values[mask@data@values!=2] <- NA

model <- readRDS("models/quality_doug_ffs.RDS")
selvar <- raster::stack("data/stacked_selected_vars/doug.grd")
selvar <- mask(selvar, mask)

start_time <- Sys.time()
pred <- predict(selvar, model)
end_time <- Sys.time()
end_time - start_time

r <- writeRaster(pred, "prediction/doug_main.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(pred, "prediction/doug_main.RDS")

# Pine #### 
mask <- prediction
mask@data@values[mask@data@values!=5] <- NA

model <- readRDS("models/quality_pine_ffs.RDS")
selvar <- raster::stack("data/stacked_selected_vars/pine.grd")
selvar <- mask(selvar, mask)

start_time <- Sys.time()
pred <- predict(selvar, model)
end_time <- Sys.time()
end_time - start_time

r <- writeRaster(pred, "prediction/pine_main.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(pred, "prediction/pine_main.RDS")


