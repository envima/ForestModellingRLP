#' @name 003_validation.R
#' 
#' 


df =readRDS("D:/forest_modelling/ForestModellingRLP/data/validation/meta_classes_diverse_confusionmatrix.RDS")
diverse= confusionMatrix_ggplot(caretConfMatr = df)
diverse



df =readRDS("D:/forest_modelling/ForestModellingRLP/data/validation/meta_classes_main_trees_confusionmatrix.RDS")
main= confusionMatrix_ggplot(caretConfMatr = df)
main
