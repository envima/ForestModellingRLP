#' @name 012_validation.R
#' @docType function
#' @description 
#' @param 
#' @param 
#' @return 

## input
polygons = sf::read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Exp_Shape_Wefl_UTM/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.shp") %>% st_drop_geometry()
# relevant class information from original polygons
polygons = polygons[,c("FAT__ID", "Phase", "BAGRu")]

rlp_extract = readRDS(file.path(envrmt$model_training_data, "RLP_extract.RDS"))

# start

`%not_in%` <- purrr::negate(`%in%`)



# attach relevant class information to full extraction set
# format properly

rlp_extract = merge(rlp_extract, polygons, by = "FAT__ID")
rlp_extract$surface_intensity_mean = NULL
rlp_extract$ID = NULL
rlp_extract$Quality = paste0(rlp_extract$BAGRu, "_", rlp_extract$Phase)



# validation for each model
models = c("main", "diverse")

for(m in models){
  meta = list()
  training_set = readRDS(file.path(envrmt$model_training_data, paste0(m,".RDS")))
  
  meta$'Model' = m
  meta$'Number of training polygons' = length(unique(training_set$FAT__ID))
  meta$'Number of training pixel per class' = as.list(table(training_set$BAGRu))
  
  rlp_extract_sub = rlp_extract %>% filter(BAGRu %in% unique(training_set$BAGRu)) %>% filter(FAT__ID %not_in% training_set$FAT__ID)
  rlp_extract_sub = na.omit(rlp_extract_sub)
  
  meta$'Number of validation polygons' = length(unique(rlp_extract_sub$FAT__ID))
  meta$'Number of validation pixel per class' = as.list(table(rlp_extract_sub$BAGRu))
  
  
  # load model
  mod = readRDS(file.path(envrmt$models, paste0(m, "_ffs.RDS")))
  valid = stats::predict(object = mod, newdata = rlp_extract_sub)
  
  val_df = data.frame(FAT__ID = rlp_extract_sub$FAT__ID,
                      Observed = rlp_extract_sub$BAGRu, 
                      Predicted = valid)
  
  val_cm = confusionMatrix(table(val_df[,2:3]))
  
  
  # output
  
  saveRDS(val_df, paste0("data/validation/", m, "_validation_df.RDS"))
  saveRDS(val_cm, paste0("data/validation/", m, "_confusionmatrix.RDS"))
  yaml::write_yaml(yaml::as.yaml(meta), file = paste0("data/validation/", m, "_meta.yaml"))
}



# Quality models

models = c("quality_beech", "quality_doug", "quality_larch", "quality_lbk",
           "quality_lbl", "quality_oak", "quality_pine", "quality_spruce")

for(m in models){
  meta = list()
  training_set = readRDS(paste0("data/model_training_data/", m,".RDS"))
  
  meta$'Model' = m
  meta$'Number of training polygons' = length(unique(training_set$FAT__ID))
  meta$'Number of training pixel per class' = as.list(table(training_set$Quality))
  
  rlp_extract_sub = rlp_extract %>% filter(Quality %in% unique(training_set$Quality)) %>% filter(FAT__ID %not_in% training_set$FAT__ID)
  rlp_extract_sub = na.omit(rlp_extract_sub)
  
  meta$'Number of validation polygons' = length(unique(rlp_extract_sub$FAT__ID))
  meta$'Number of validation pixel per class' = as.list(table(rlp_extract_sub$Quality))
  
  
  # load model
  mod = readRDS(paste0("data/models/", m,"_ffs.RDS"))
  valid = stats::predict(object = mod, newdata = rlp_extract_sub)
  
  val_df = data.frame(FAT__ID = rlp_extract_sub$FAT__ID,
                      Observed = rlp_extract_sub$Quality, 
                      Predicted = valid)
  
  val_cm = confusionMatrix(table(val_df[,2:3]))
  
  
  # output
  
  saveRDS(val_df, paste0("data/validation/", m, "_validation_df.RDS"))
  saveRDS(val_cm, paste0("data/validation/", m, "_confusionmatrix.RDS"))
  yaml::write_yaml(yaml::as.yaml(meta), file = paste0("data/validation/", m, "_meta.yaml"))
}


