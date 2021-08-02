#' @name 004_Hansen.R
#'

# input
# load tree cover tiles for RLP year 2000 
listOfFiles = list.files("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/hansen/", pattern = "treecover2000", full.names = TRUE)


treeCover2000 = merge_crop_raster(listOfFiles,
                  border = read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Landesgrenze_RLP/Landesgrenze_RLP.shp"),
                  changeBorderCrs = TRUE,
                  buffer = 200)


#load and crop lossyear2018

listOfFiles = list.files("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/hansen/", pattern = "loss", full.names = TRUE)

lossYear2018 = merge_crop_raster()


# 2.1 - calculate tree cover 2018
#--------------------------------------
lossYear2018RLP[lossYear2018RLP > 0] <- NA # all forest loss should be removed from treeCover
lossYear2018RLP[lossYear2018RLP == 0] <- 1 # other values should stay the same

# remove larger values and set NA values to 0
treeCover2018 <- treeCover2000RLP/lossYear2018RLP
treeCover2018[is.na(treeCover2018[])] <- 0 

writeRaster(treeCover2018, file.path(envrmt$path_hansen, "treeCover2018.tif"), overwrite = TRUE)




