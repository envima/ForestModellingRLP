#' @name 006a_balancing.R
#' @docType function
#' @description 
#' @param 
#' @return 



# input
extr = readRDS(file.path("data/model_training_data/RLP_extract.RDS"))
polygons = st_read("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Exp_Shape_Wefl_UTM/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.shp") %>% st_drop_geometry()
polygons = polygons[,c("FAT__ID", "Phase", "BAGRu")]
extr = merge(extr, polygons, by = "FAT__ID")
rm(polygons)



class_min_poly <- function(df, var) {
  
  # number of polygons per class
  no_pol = df %>% 
    group_by((!!sym(var))) %>% 
    count() 
  
  # determine class with least polygons
  no_pol_min = no_pol %>% filter(n == min(no_pol$n))
  return(no_pol_min)
}




#-------------------
extr_org = extr

# group by BAGRu und FID to get number of pixel for each polygon
extr = extr %>% 
  filter(BAGRu %in% c("Fi", "Ei", "Ki", "Bu", "Dou"))%>% 
  group_by(BAGRu, FAT__ID) %>% 
  count()

polMin = class_min_poly(df = extr, var = "BAGRu")

# create statistics for class with least polygons
stats = extr %>% 
  filter (BAGRu == polMin[[1]]) %>% 
  pull(n) %>%
  summary()

# filtering polygons by size. 
# Minimum number of pixels = first quantile of the class with the fewest polygons. 
# Maximum number of pixels per polygon = third quantile of the class with the fewest polygons.
extr = extr %>% filter(n > stats[[2]],
                       n < stats[[5]]) 


# count all remaining polygons. 
# The class with the fewest determines how many are sampled per class.
polMin = class_min_poly(df = extr, var = "BAGRu")


# choose random polygons from each class 
extr = extr %>% 
  group_by(BAGRu) %>% 
  dplyr::slice_sample(n = no_pol_min[[2]])

#----------------------------
#
#       Filtern nach pixelanzahl
#
#----------------------------

# merge with original datafram to get back to pixel information
df = extr_org %>% filter(FAT__ID %in% extr$FAT__ID)

# determine number of pixel for each class
polMin = class_min_poly(df = df, var = "BAGRu")



#### min pixel number dou = 12585
#-------------------------------------

df = df %>% 
  group_by(BAGRu) %>%
  dplyr::slice_sample(n = polMin[[2]])


return(df)




