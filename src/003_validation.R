#' @name 003_validation.R
#' sub control script for data preparation
#'
#'
#' @description Use this script for controlling the processing.
#'
#' @author [name], [email@com]
#'

library(envimaR)
library(rprojroot)
root_folder = find_rstudio_root_file()

source(file.path(root_folder, "src/functions/000_setup.R"))

# 1 - validation ####
#-------------------#





# 2 - confusion matrices ####
#---------------------------#
df =readRDS("D:/forest_modelling/ForestModellingRLP/data/validation/meta_classes_diverse_confusionmatrix.RDS")
diverse= confusionMatrix_ggplot(caretConfMatr = df)
diverse



df =readRDS("D:/forest_modelling/ForestModellingRLP/data/validation/meta_classes_main_trees_confusionmatrix.RDS")
main= confusionMatrix_ggplot(caretConfMatr = df)
main


# 3 - successional stages confusion matrices ####
#-----------------------------------------------#

lstFiles = list.files("D:/forest_modelling/ForestModellingRLP/data/validation/", full.names = TRUE, pattern = glob2rx("quality*confusionmatrix.RDS"))

cm <- readRDS(lstFiles[[1]])
cm <- as.data.frame(cm$table)

cm$Observed <- factor(cm$Observed,levels = c("Bu_Qua", "Bu_Dim", "Bu_Rei"))
cm$Predicted <- factor(cm$Predicted,levels = c(  "Bu_Rei",  "Bu_Dim","Bu_Qua"))


plot_Buche = successional_stages_cm(cm)

cm <- readRDS("D:/forest_modelling/ForestModellingRLP/data/validation/quality_pine_confusionmatrix.RDS")
cm <- as.data.frame(cm$table)

cm$Observed <- factor(cm$Observed,levels = c("Ki_Dim", "Ki_Rei"))
cm$Predicted <- factor(cm$Predicted,levels = c( "Ki_Rei",  "Ki_Dim"))

plot_Ki = successional_stages_cm(cm)

# 3 - table metadata ####
#-----------------------#

lstYaml = list.files("D:/forest_modelling/ForestModellingRLP/data/validation/", pattern = ".yaml", full.names = TRUE)

meta_table = table_metadata(lstYaml)
