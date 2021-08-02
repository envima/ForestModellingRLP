#date: 14.07.2020
#name: LIDAR_Sentinel_Stack_RLP.R
#data:                                               
#output: 
#----------------------------------------------------------

# 1 - load libraries and working Environment
#--------------------------------------------
source(file.path(envimaR::alternativeEnvi(root_folder = "C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu"),
                 "src/setup_forest_modelling.R"))



# 2 - rasterDB
#------------------------

library(RSDB)

# set account
#userpwd <- "user:password" # use this account (if not loaded from file)
fileName <- file.path(envrmt$path_src, "remote_sensing_userpwd.txt") # optional file in home directory content: user:password
userpwd <- readChar(fileName, file.info(fileName)$size) # optional read account from file

# open remote sensing database
#remotesensing <- RemoteSensing$new("http://localhost:8081", userpwd) # local
remotesensing <- RemoteSensing$new("http://192.168.191.183:8081", "") # remote server
#remotesensing <- RemoteSensing$new("http://137.248.191.215:8081", userpwd) # remote server

# get names of RasterDBs
remotesensing$rasterdbs

# get one rasterdb
rasterdb <- remotesensing$rasterdb("RLP_forest_mask_20m_i4")


# polygone

rlp_forest = st_read("data/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.shp")
rlp_forest = st_transform(rlp_forest, crs = 25832)


# negative buffer to remove edge effects
rlp_forest_buffer = st_buffer(rlp_forest, dist = -20)
rlp_forest_buffer = rlp_forest_buffer[!st_is_empty(rlp_forest_buffer),]



# 3 - load sentinel data
#-------------------------

summerRLP <- stack("data/Sentinel_RLP/summerRLP.grd")
winterRLP <- stack("data/Sentinel_RLP/winterRLP.grd")
summerIndices <- stack("data/Sentinel_RLP/indicesSummerRLP.grd")
winterIndices <- stack("data/Sentinel_RLP/indicesWinterRLP.grd")


# rename bands
names(summerRLP) = paste0(names(summerRLP), "_summer")
names(winterRLP) = paste0(names(winterRLP), "_winter")
names(summerIndices) = paste0(names(summerIndices), "_summer")
names(winterIndices) = paste0(names(winterIndices), "_winter")

RLPsen <- raster::stack(summerRLP, winterRLP, summerIndices, winterIndices)





# extract all polygons from raster stack
i = 340
result = lapply(seq(nrow(rlp_forest_buffer)), function(i){
  print(i)
  cur = rlp_forest_buffer[i,]
  ext <- extent(cur)
  
  LIDARIndices <- rasterdb$raster(ext)
  LIDARIndices = dropLayer(LIDARIndices, "band1") 
  
  chm = LIDARIndices$chm_height_max
  chm = extract(chm, cur, df = TRUE)
  
  # check if polygon only contains one row
  if(nrow(chm) < 6){
    print("Small Polygon")
    return("Small")
    
  }

  # check if all chm values are FALSE
  if(all(is.na(chm$chm_height_max))){
    print("Luxemburg")
    return("Luxemburg")
  }
  
  # check if mean canopy height is larger than 10m
  if(mean(chm[,2], na.rm = TRUE) < 10){
    print("Smaller 10")
    return("Smaller10")
  }else{
    
    # if bigger than 10 m:
    sen = crop(RLPsen, ext)
    sen = raster::projectRaster(sen, LIDARIndices)
    
    all = stack(LIDARIndices, sen)
    
    df = extract(all, cur, df = TRUE)
    df$FAT__ID = cur$FAT__ID
    print("Extracted")
    return(df)
  }
  
})


# backup save
saveRDS(result, "~/temp/RLP_extract_backup.RDS")



# processing protocoll
protocoll = lapply(result, function(r){
  
  if(is.data.frame(r)){
    return(as.character(nrow(r)))
  }else if(r == "Luxemburg"){
    return("UTM31")
  }else if(r == "Smaller10"){
    return("LowCanopyHeight")
  }else if(r == "Small"){
    return("SmallPolygon")
  }else{
    return("Error")
  }
  
})
p = data.frame(FAT__ID = rlp_forest_buffer$FAT__ID, 
               status = do.call(c, protocoll))
write.csv(p, "data/RLP_extration_protocoll.csv", quote = FALSE, row.names = FALSE)


# foramting of extraction

res = result[sapply(result, is.data.frame)]
res = do.call(rbind, res)
saveRDS(res, "data/RLP_extract.RDS")



