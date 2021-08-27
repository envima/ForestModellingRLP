#' @name 006_extraction.R
#' @description 
#' @docType function
#' @param pol sf object
#' @param rasterStack terra rast object
#' @param bufferSize default = -20
#' @param idColName string default = "ID"
#' @return 
#' 


extraction <- function(rasterStack, pol, bufferSize = -20, idColName = "FAT__ID") {
  
if (bufferSize != 0) {
  pol = st_buffer(pol, dist = bufferSize)
  pol = pol[!st_is_empty(pol),]
}


# extract all polygons from raster stack
result = lapply(seq(nrow(pol)), function(i){
  cur = pol[i,]
  ext <- terra::ext(cur)
  
   
  all = terra::crop(rasterStack, ext)
  
   #check if all chm values are FALSE
    if (raster::hasValues(all))
  has.data = which(!is.na(raster::getValues(max(all, na.rm=TRUE))))
  if(all(is.na(values(all$)))){
  print("no values")
    return("no values")
  }
  
  
  df = terra::extract(all, vect(cur), df = TRUE)
  df = df %>% dplyr::mutate(cur %>% select(idColName))
  df$ID <- NULL
  
  print(paste("Extracted Polygon", i, "of", nrow(pol)))
  return(df)

}) # end lapply


# backup save
saveRDS(result, "~/temp/RLP_extract_backup.RDS")



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

} # end of function


