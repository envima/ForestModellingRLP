#' @name 012_validation.R
#' @docType function
#' @description 
#' @param extr = rlp_extr
#' @param model = "main"
#' @param idCol = "FAT__ID"
#' @param responseCol = "BAGRu"
#' @return 


validation = function(extr,
                      model = "main", 
                      idCol = "FAT__ID", 
                      responseCol = "BAGRu") {
  
  `%not_in%` <- purrr::negate(`%in%`)
  
  # validation for each model
  
  
  meta = list()
  training_set = readRDS(file.path(envrmt$model_training_data, paste0(model,".RDS")))
  
  meta$'Model' = m
  meta$'Name' = m
  meta$'Number of training polygons' = training_set %>% select(all_of(idCol)) %>% n_distinct()
  meta$'Number of training pixel per class' = as.list(table(select(training_set, all_of(responseCol))))
  meta$'Number of training pixel' = sum(table(select(training_set, all_of(responseCol))))
  
  
  extr_sub = extr %>% 
    filter((!!sym(responseCol)) %in% 
             (distinct(training_set, (!!(sym(responseCol)))) %>% pull())
    ) %>% #end filter
    filter((!!sym(idCol)) %not_in% pull(training_set, idCol)
    ) # end filter
  
  
  extr_sub = na.omit(extr_sub)
  
  meta$'Number of validation polygons' = extr_sub %>% select(all_of(idCol)) %>% n_distinct()       
  meta$'Number of validation pixel per class' = as.list(table(select(extr_sub, all_of(responseCol))))
  meta$'Number of validation pixel' = sum(table(select(extr_sub, all_of(responseCol))))
  
  
  # load model
  mod = readRDS(file.path(envrmt$models, paste0(m, "_ffs.RDS")))
  valid = stats::predict(object = mod, newdata = extr_sub)
  
  val_df = data.frame(ID = pull(extr_sub, idCol),
                      Observed = pull(extr_sub, responseCol), 
                      Predicted = valid)
  
  names(val_df)[names(val_df) == "ID"] <- idCol
  
  
  val_cm = confusionMatrix(table(val_df[,2:3]))
  
  
  # output
  saveRDS(val_cm, paste0(file.path(envrmt$validation), m, "_confusionmatrix.RDS"))
  yaml::write_yaml(yaml::as.yaml(meta), file = paste0(file.path(envrmt$validation), m, "_meta.yaml"))
  
  
} # end of function
