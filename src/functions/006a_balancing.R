#' @name 006a_balancing.R
#' @docType function
#' @description 
#' @param extr extraction dataframe
#' @param class = c("Fi", "Ei", "Ki", "Bu", "Dou")
#' @param response = "BAGRu"
#' @return df 


balancing <- function(extr, 
                      response = "BAGRu", 
                      class = c("Fi", "Ei", "Ki", "Bu", "Dou")) {
  
  ######################################
  # small helper function to determine #
  # class with least polygons/pixel    #
  ######################################
  
  class_min_poly <- function(df, var) {
    
    # number of polygons per class
    no_pol = df %>% 
      group_by((!!sym(var))) %>% 
      count() 
    
    # determine class with least polygons
    no_pol_min = no_pol %>% filter(n == min(no_pol$n))
    return(no_pol_min)
  }
  
  
  
  
  # safe org dataset
  extr_org = extr
  
  # part 1: filter by polygons
  
  # group by BAGRu und FID to get number of pixel for each polygon
  extr = extr %>% 
    filter((!!sym(response)) %in% class)%>% 
    group_by((!!sym(response)), FAT__ID) %>% 
    count()
  
  polMin = class_min_poly(df = extr, var = response)
  
  # create statistics for class with least polygons
  stats = extr %>% 
    filter ((!!sym(response)) == polMin[[1]]) %>% 
    pull(n) %>%
    summary()
  
  # filtering polygons by size. 
  # Minimum number of pixels = first quantile of the class with the fewest polygons. 
  # Maximum number of pixels per polygon = third quantile of the class with the fewest polygons.
  extr = extr %>% filter(n > stats[[2]],
                         n < stats[[5]]) 
  
  
  # count all remaining polygons. 
  # The class with the fewest determines how many are sampled per class.
  polMin = class_min_poly(df = extr, var = response)
  
  
  # choose random polygons from each class 
  extr = extr %>% 
    group_by((!!sym(response))) %>% 
    dplyr::slice_sample(n = polMin[[2]])
  
  # part 2: filter by number of pixels
  
  # merge with original dataframe to get back to pixel information
  df = extr_org %>% filter(FAT__ID %in% extr$FAT__ID)
  
  # determine number of pixel for each class
  polMin = class_min_poly(df = df, var = response)
  
  
  
  #### min pixel number dou = 12585
  #-------------------------------------
  
  df = df %>% 
    group_by((!!sym(response))) %>%
    dplyr::slice_sample(n = polMin[[2]])
  
  
  return(df)
  
} # end of function


