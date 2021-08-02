######################################################## Begin Function 

#########################################
# Function: LIDAR_Indices               #
# Aim: calculate all LIDAR Indices for  #
#      each polygon in spatial Polygon  #
#      Dataframe                        #
# Needs:                                #
#       spdf: polygons as spatial       #
#             polygon data frame        #
#       ID_Col: number of column in spdf#
#               that contains ID        #
#               information             #
#                                       #
# Return: dataframe with all Indices;   #
#         column "name" contains polygon#
#         ID                            #
#########################################


LIDAR_Indices <- function(spdf, ID_Col) {
  ind <- data.frame() # empty data frame for indices
  colnames(spdf@data)[ID_Col] <- "ID" # rename ID column to "ID"
  steps <- 1 # count 
  
  for (i in 1:length(spdf)){
    p <- Polygon(coords=spdf@polygons[[i]]@Polygons[[1]]@coords)# polygon with extent of ROIs
    df <- pointcloud$indices(list(p1=p), pointcloud$index_list$name) # calculate all indices for polygon
    
    if (length(row.names(df)) != 0) {
      df$name[[1]] <- spdf@data$ID[[i]] # rename to ID
      ind <- rbind(ind, df) 
     } else {
       df[1, ] <- c(rep(NA, ncol(df)))
       df$name[1] <- spdf@data$ID[[i]] # rename to FAT_ID
       ind <- rbind(ind, df) 
       cat(paste("Error in Polygon", spdf@data$ID[[i]], "\n"))
      }
    
    cat(paste(steps, "of", length(spdf@data$ID), "\n"))
    steps <- steps+1
  } # end for loop
 
   return (ind)
} 
#################################################### end function

