# name: aoa_doug_and_lbl.R
# date: 23 03 2021
# data: models, pred stacks
# output: area of applicability - https://arxiv.org/abs/2005.07939


# 1 - set up ####
#------------------------------

require(raster)
require(CAST)


# 1 - aoa of diverse long-lived deciduous trees ####
#---------------------------------------------------

mask <- raster::stack("data/prediction/diverse_trees_pred.grd")
mask[mask != 8 ] <- NA
model <- readRDS(paste0("data/models/quality_lbl_ffs.RDS"))
selvar <- raster::stack(paste0("data/stacked_selected_vars/lbl.grd"))
selvar <- raster::mask(selvar, mask)
rm(mask)


start_time <- Sys.time()

aoa <- CAST::aoa(
  newdata = selvar,
  model = model)


end_time <- Sys.time()
attributes(aoa)$aoa_stats

print(paste("finished aoa lbl in ", end_time - start_time, " minutes"))

r <- writeRaster(aoa, paste0("data/aoa_diverse/aoa_lbl_diverse.grd"), overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(aoa, paste0("data/aoa_diverse/aoa_lbl_diverse.RDS"))



# 3 - aoa of main douglas fir ####
#---------------------------------


mask <- raster::stack("data/prediction/main_trees_pred.grd")
mask[mask != 2 ] <- NA
model <- readRDS("data/models/quality_doug_ffs.RDS")
selvar <- raster::stack("data/stacked_selected_vars/doug.grd")
selvar <- mask(selvar, mask)
rm(mask)

start_time <- Sys.time()

aoa <- CAST::aoa(
  newdata = selvar,
  model = model)


end_time <- Sys.time()

print(paste("finished aoa doug in ", end_time - start_time, " minutes"))

r <- writeRaster(aoa, "data/aoa_diverse/aoa_doug_main.grd", overwrite = TRUE) #save raster
hdr(r, format = "ENVI")
saveRDS(aoa,"data/aoa_diverse/doug_main.RDS")

