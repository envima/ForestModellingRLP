#' @name 007_balancing.R
#' @description 
#' @docType function
#' @param pred_resp
#' @param response = "BAGRu"
#' @param idCol = "FAT__ID"
#' @param class = c("Fi", "Ei", "Ki", "Bu", "Dou")


balancing <- function(pred_resp, idCol = "FAT__ID", response = "BAGRu", class = c("Fi", "Ei", "Ki", "Bu", "Dou")) {
  
  pred_resp = pred_resp%>% filter((!!sym(response)) %in% class)
  #nrow per class
  dens = count(pred_resp, all_of(response))
  colnames(dens) <- c("Var1", "Freq")
  
  
  #number of locations per class before subsetting
  dens_plots = pred_resp %>%
    group_by((!!sym(response))) %>%
    dplyr::summarize(number_of_distinct_locations = n_distinct((!!sym(idCol))))
  
  
  #number of samples per location
  dens_ID = count(pred_resp, all_of(idCol))
  colnames(dens_ID) <- c("Var1", "Freq")
  
  
  #get min required number of samples per location
  balance_df<-data.frame()
  
  for(i in 1:200){
    
    min_ID<-dens_ID[dens_ID$Freq>=i,]
    
    #get IDs of remaining locations 
    location_ID<-unique(min_ID$Var1)
    
    #subset data frame
    pred_resp_SUB <- pred_resp %>% filter((!!sym(idCol)) %in% location_ID)
    
    #number of remaining training locations per class
    train_dens = pred_resp_SUB %>%
      group_by((!!sym(response))) %>%
      dplyr::summarize(number_of_distinct_locations = n_distinct((!!sym(idCol))))
    
    #number of samples per class
    train_dens$sampels<-train_dens$number_of_distinct_locations*i
    train_dens$min_samples<-i
    
    balance_df<-rbind(balance_df,train_dens) 
  } # end for loop
  
  
  
  # determine smallest class
  balancer = balance_df %>% filter(sampels == min(balance_df$sampels))

  balancer_df = balance_df%>% filter((!!sym(response)) == balancer[[1]])
  print(paste0("The poorest represented class is: ", balancer[[1]], ". It is used as balancer."))
  max_balancer<-balancer_df[balancer_df$sampels==max(balancer_df$sampels),]
  
  if (nrow(max_balancer)>1) {
    max_balancer <- max_balancer%>%filter(max_balancer$number_of_distinct_locations == max(max_balancer$number_of_distinct_locations))
  }
  
  balance_all<-balance_df[balance_df$min_samples== max_balancer[[4]],]
  
  
  ##
  min_ID<-dens_ID[dens_ID$Freq>=max_balancer[[4]],]
  
  #get IDs of remaining locations 
  location_ID<-unique(min_ID$Var1)
  
  #subset data frame
  pred_resp_SUB<-pred_resp %>% filter((!!sym(idCol)) %in% location_ID)
  
  
  
  ####
  # equal number of samples per location
  pred_resp_SUB = pred_resp_SUB %>%
    group_by((!!sym(idCol))) %>% 
    dplyr::slice_sample(n = max_balancer[[4]])
  
  dens = pred_resp_SUB %>%
    group_by((!!sym(response))) %>%
    dplyr::summarize(number_of_distinct_locations = n_distinct((!!sym(idCol))))
  
  
  ##get subset IDs
  IDs<-NULL
  for(i in class){
    
    tmp = pred_resp_SUB %>% filter((!!sym(response)) ==i)
    ID = tmp%>% 
      pull(idCol) %>%
      unique() %>%
      sample(min(dens$number_of_distinct_locations)) %>% 
      as.character()
    
    IDs<-c(ID,IDs)
  } # end for loop
  
  
  #subset data
  balanced_pred_resp<- pred_resp_SUB %>% 
    filter((!!sym(idCol)) %in% IDs)
  
  
  return(balanced_pred_resp)
} # end of function
