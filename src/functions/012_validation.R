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
rlp_extract = readRDS("C:/Users/Lisa Bald/Uni_Marburg/forest_modelling_rlp/ForestModellingRLP/data/model_training_data/RLP_extract.RDS")
# attach relevant class information to full extraction set
# format properly
rlp_extract = merge(rlp_extract, polygons, by = "FAT__ID")
rm(polygons)
rlp_extract$surface_intensity_mean = NULL
rlp_extract$ID = NULL

rlp_extract$Quality = paste0(rlp_extract$BAGRu, "_", rlp_extract$Phase)

extr = rlp_extract

models = c("main", "diverse")
idCol = "FAT__ID"
responseCol = "BAGRu"


#---------------------------

validation = function(models = c("main", "diverse"), 
                      idCol = "FAT__ID", 
                      responseCol = "BAGRu") {

`%not_in%` <- purrr::negate(`%in%`)

# validation for each model

for(m in models){
  meta = list()
  training_set = readRDS(file.path(envrmt$model_training_data, paste0(m,".RDS")))
  
  meta$'Model' = m
  meta$'Name' = m
  meta$'Number of training polygons' = training_set %>% select(all_of(idCol)) %>% n_distinct()
  meta$'Number of training pixel per class' = as.list(table(select(training_set, all_of(responseCol))))
  meta$'Number of training pixel' = sum(table(select(training_set, all_of(responseCol))))
  
  
  rlp_extract_sub_v = rlp_extract %>% 
    filter((!!sym(responseCol)) %in% 
             (distinct(training_set, (!!(sym(responseCol)))) %>% pull())
    ) %>% #end filter
    filter((!!sym(idCol)) %not_in% pull(training_set, idCol)
    ) # end filter
  
  
  rlp_extract_sub = na.omit(rlp_extract_sub)
  
  meta$'Number of validation polygons' = rlp_extract %>% select(all_of(idCol)) %>% n_distinct  length(unique(rlp_extract_sub$FAT__ID))
  meta$'Number of validation pixel per class' = as.list(table(rlp_extract_sub$BAGRu))
  
  
  # load model
  mod = readRDS(file.path(envrmt$models, paste0(m, "_ffs.RDS")))
  valid = stats::predict(object = mod, newdata = rlp_extract_sub)
  
  val_df = data.frame(FAT__ID = rlp_extract_sub$FAT__ID,
                      Observed = rlp_extract_sub$BAGRu, 
                      Predicted = valid)
  
  val_cm = confusionMatrix(table(val_df[,2:3]))
  
  
  # output
  saveRDS(val_cm, paste0(file.path(envrmt$validation), m, "_confusionmatrix.RDS"))
  yaml::write_yaml(yaml::as.yaml(meta), file = paste0(file.path(envrmt$validation), m, "_meta.yaml"))
}

} # end of function
