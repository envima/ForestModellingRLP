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

polygons = sf::read_sf(file.path(envrmt$FID, "Trainingsgebiete_RLP.gpkg")) %>% st_drop_geometry()
# relevant class information from original polygons
polygons = polygons[,c("FAT__ID", "Phase", "BAGRu")]
# attach relevant class information to full extraction set
extract = readRDS(file.path(envrmt$model_training_data, "extract.RDS"))

# format properly
extract = merge(extract, polygons, by = "FAT__ID")
rm(polygons)
extract$surface_intensity_mean = NULL
extract$ID = NULL

extract$Quality = paste0(extract$BAGRu, "_", extract$Phase)

for (i in c("main", "diverse", "Bu", "Fi", "Ei", "Dou", "Lä", "Ki", "Lbk", "Lbl")) {
  validation(extr = extract,
             model = "main", 
             idCol = "FAT__ID", 
             responseCol = "BAGRu") 
  
} # end for loop


# 2 - confusion matrices ####
#---------------------------#

models = c("main", "diverse")

for (m in models) {
  df = readRDS(file.path(envrmt$confusionmatrix, paste0(m, "_confusionmatrix.RDS")))
  cm = confusionMatrix_ggplot(caretConfMatr = df)
  ggsave(plot = cm, path = file.path(envrmt$illustrations), 
         filename = paste0(m, "_confusionmatrix.png"),
         width = 10,
         height = 7,
         dpi = 400)
}

# 3 - successional stages confusion matrices ####
#-----------------------------------------------#

lstFiles = list.files("E:/Waldmodellierung/ForestModellingRLP/data/validation/", full.names = TRUE, pattern = glob2rx("quality*confusionmatrix.RDS"))
cm <- readRDS(lstFiles[[1]])
cm <- as.data.frame(cm$table)

levels(cm$Observed)
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

lstYaml = list.files("E:/Waldmodellierung/ForestModellingRLP/data/validation/", pattern = ".yaml", full.names = TRUE)
meta_table = table_metadata(lstYaml)
gtsave(meta_table,
       filename = "no_training_pixel_table.png",
       path = file.path(envrmt$illustrations))

# 4 - table selected variables ####
#---------------------------------#



# 5 - selected variables plots ####
#---------------------------------#


