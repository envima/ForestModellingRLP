#' @name 012_validation.R
#' @docType function
#' @description 
#' @param extr = rlp_extr
#' @param model = "main"
#' @param idCol = "FAT__ID"
#' @param responseCol = "BAGRu"
#' @return 


validation_aoa = function(extr,
                          model = "main", 
                          idCol = "FAT__ID", 
                          responseCol = "BAGRu",
                          FID = sf::read_sf(file.path(envrmt$FID, "Trainingsgebiete.gpkg"))
                          ) {
  
  `%not_in%` <- purrr::negate(`%in%`)
  
  # validation for each model
  
  
  meta = list()
  training_set = readRDS(file.path(envrmt$model_training_data, paste0(model,".RDS")))
  
  meta$'Model' = model
  meta$'Number of training polygons' = training_set %>% select(all_of(idCol)) %>% n_distinct()
  meta$'Number of training pixel per class' = max(table(select(training_set, all_of(responseCol))))
  meta$'Number of training pixel' = sum(table(select(training_set, all_of(responseCol))))
  
  
  extr_sub = extr %>% 
    filter((!!sym(responseCol)) %in% 
             (distinct(training_set, (!!(sym(responseCol)))) %>% pull())
    ) %>% #end filter
    filter((!!sym(idCol)) %not_in% pull(training_set, idCol)
    ) # end filter
  
  
  
  ids = extr_sub %>% select(all_of(idCol)) %>% unique()
  FID = FID %>% dplyr::filter(FAT__ID %in% ids[[1]])
  
  # delete prediction from aoa
  pred = terra::rast(file.path(envrmt$prediction, paste0(model, "_pred.tif")))
  #pred = readRDS(file.path(envrmt$prediction, paste0(model, "_pred.RDS")))
  aoa = terra::rast(file.path(envrmt$aoa, paste0(model, "_aoa.tif")))
  aoa = aoa[[2]]
  aoa[aoa == 0] <- NA
  pred = terra::mask(pred, aoa)
  
  FID$ID = c(1:nrow(FID))
  FID = sf::st_transform(FID, crs(pred))
  
  
  # extract and merge with ID
  extr = terra::extract(pred, vect(FID))
  FID = select(FID, c(all_of(idCol),all_of(responseCol)))
  FID$ID = c(1:nrow(FID))
  df = merge(extr, FID, by.x = 'ID', by.y = 'ID')
  df = na.omit(df)
  
  # create validation dataframe
  val_df = data.frame(ID = df %>% pull(all_of(idCol)),
                      Observed = df %>% pull (all_of(responseCol)), 
                      Predicted = df %>% pull(all_of(category))
  )
  
  # format levels and class of dataframe
  val_df$Observed <- as.factor(val_df$Observed)
  val_df$Predicted <- as.factor(val_df$Predicted)
  val_df$Predicted <-  droplevels(val_df$Predicted)
  
  
  names(val_df)[names(val_df) == "ID"] <- idCol
  
  
  val_cm = confusionMatrix(table(val_df[,2:3]))
  
  
  
  meta$'Number of validation polygons' = val_df %>% select(all_of(idCol)) %>% n_distinct()       
  meta$'Number of validation pixel per class' = as.list(table(select(val_df, Observed)))
  meta$'Number of validation pixel' = sum(table(select(val_df,Observed)))
  
  
  
  # output
  saveRDS(val_cm, file.path(envrmt$confusionmatrix, paste0(model, "_confusionmatrix.RDS")))
  yaml::write_yaml(yaml::as.yaml(meta), file = file.path(envrmt$confusionmatrix, paste0(model, "_meta.yaml")))
  
  
  
} # end of function
