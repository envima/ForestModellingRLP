#' @name 006_extraction.R
#' @description 
#' @docType function
#' @param pol sf object
#' @param rasterStack terra rast object
#' @param bufferSize default = -20
#' @param idColName string default = "ID"
#' @return 
#' 


extraction <- function(rasterStack, pol, bufferSize = -20, idColName = "FAT__ID", extrProtocollOut) {
  
  if (bufferSize != 0) {
    pol = st_buffer(pol, dist = bufferSize)
    pol = pol[!st_is_empty(pol),]
  }

  # extract all polygons from raster stack
  result = lapply(seq(nrow(pol)), function(i){
    cur = pol[i,]
    ext <- terra::ext(cur)
    
<<<<<<< HEAD
    LIDARIndices <- rasterdb$raster(ext)
    LIDARIndices = dropLayer(LIDARIndices, "band1") 
    #all = terra::crop(rasterStack, ext)
    chm = LIDARIndices$chm_height_max
=======
    
    chm = rasterStack$chm_height_max
>>>>>>> 7b7e914c6a096582107e0dcb323a3aa1e87370b6
    chm = terra::extract(chm, vect(cur), df = TRUE)
    
    # check if polygon only contains one row
    if(nrow(chm) < 6){
      print("Small Polygon")
      return("Small")
      
    }
    
    # check if all chm values are FALSE
    if(all(is.na(chm$chm_height_max))){
      print("Luxemburg")
      return("Luxemburg")
    } else {
      
<<<<<<< HEAD
      sen = terra::crop(rasterStack, ext)
      all = rast(list(LIDARIndices, sen))
      
=======
      all = terra::crop(rasterStack, ext)
>>>>>>> 7b7e914c6a096582107e0dcb323a3aa1e87370b6
      
      df = terra::extract(all, vect(cur), df = TRUE)
      df = df %>% dplyr::mutate(cur %>% select((!!sym(idColName))))
      df$ID <- NULL
      
      print(paste("Extracted Polygon", i, "of", nrow(pol)))
      return(df)
    }
  }) # end lapply
  
  
  # backup save
  saveRDS(result, file.path(paste0(tempdir(), "extract_backup.RDS")))
  
  
  
  # processing protocoll
  protocoll = lapply(result, function(r){
    
    if(is.data.frame(r)){
      return(as.character(nrow(r)))
    }else if(r == "Luxemburg"){
      return("UTM31")
    }else if(r == "Small"){
      return("SmallPolygon")
    }else{
      return("Error")
    }
    
  })
  p = data.frame(FAT__ID = pull(pol, (!!sym(idColName))), 
                 status = do.call(c, protocoll))
  write.csv(p, file.path(envrmt$model_training_data, "extraction_protocoll.csv"), quote = FALSE, row.names = FALSE)
  
  
  # foramting of extraction
  
  res = result[sapply(result, is.data.frame)]
  res = do.call(rbind, res)
  return(res)
} # end of function


