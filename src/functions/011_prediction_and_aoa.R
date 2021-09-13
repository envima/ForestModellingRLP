#' @name 009_prediction_and_aoa.R
#' @docType function
#' @description
#' @param lstSpecies
#' @param lstQuality
#' 
#' 


prediction_aoa <- function(lstSpecies = c("main", "diverse"), lstQuality = "quality") {

  for (species in lstSpecies)  {
    
    mod <- readRDS(list.files(envrmt$models, pattern= species, full.names = TRUE))
    # do not choose terra package, raster attributes are still an issue here
    selvar <- raster::stack(file.path(envrmt$selected_variables,paste0(species, ".grd")))
    
    #prediction for species model
    start_time <- Sys.time()
    prediction <- terra::predict(selvar, mod, na.rm = TRUE)
    end_time <- Sys.time()
    cat("predicted ", species, " model in ",  end_time - start_time, "minutes\n")
   
    # safe prediction
    r <- writeRaster(prediction, file.path(envrmt$prediction, paste0(species, "_pred.grd")), overwrite = TRUE)
    hdr(r, format = "ENVI")
    saveRDS(prediction, file.path(envrmt$prediction, paste0(species, "_pred.RDS")))
    #---
    
    # aoa
    start_time <- Sys.time()
    aoa <- CAST::aoa(newdata = selvar,
                     model = mod)
    end_time <- Sys.time()
    cat("calculated aoa for ", species, " model in ",  end_time - start_time, "minutes\n")
    
    r <- writeRaster(aoa, file.path(envrmt$aoa, paste0(species, "_aoa.grd")), overwrite = TRUE)
    hdr(r, format = "ENVI")
    # ---
    
    # predict quality
    class = levels(prediction)[[1]]
    lst <- list.files(envrmt$models, pattern= lstQuality, full.names = FALSE)
    
    for (i in lstQuality) { # beginning for loop
      
      # create mask
      response_type <- gsub(".RDS|quality_|_ffs", "", i)
      predClass <- as.integer(class %>% filter(value == response_type) %>% select(ID))
      mask <- prediction
      mask[mask != predClass] <- NA
      
      # load model and selected variables
      model <- readRDS(file.path(envrmt$models, i))
      selvar <- raster::stack(file.path(envrmt$selected_variables, paste0(response_type, ".grd")))
      selvar <- mask(selvar, mask) # apply mask
      
      # prediction
      start_time <- Sys.time()
      pred <- predict(selvar, model)
      end_time <- Sys.time()
      
      print(paste("finished prediction ", response_type, "in ", end_time - start_time, " minutes"))
      
      r <- writeRaster(pred, file.path(envrmt$prediction, paste0(response_type, "_", species, "_pred.grd")), overwrite = TRUE) #save raster
      hdr(r, format = "ENVI")
      saveRDS(pred, file.path(envrmt$prediction, paste0(response_type, "_", species, "_pred.RDS")))
      #---
      
      # aoa
      start_time <- Sys.time()
      aoa <- CAST::aoa(newdata = selvar,
                       model = model)
      end_time <- Sys.time()
      print(paste("finished aoa for ", response_type, "in ", end_time - start_time, " minutes"))
      
      r <- writeRaster(aoa, file.path(envrmt$aoa, paste0(species, "_aoa.grd")), overwrite = TRUE)
      hdr(r, format = "ENVI")
      # ---
                                         
    } # end for loop
  } # end for loop
} # end of function


