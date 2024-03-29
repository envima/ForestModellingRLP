#' @name 003_validation.R
#' sub control script for data preparation
#'
#'
#' @description Use this script for controlling the processing.
#'
#' @author [name], [email@com]
#'

# 0 - set up ####
#---------------#

library(envimaR)
library(rprojroot)
root_folder = find_rstudio_root_file()

source(file.path(root_folder, "src/functions/000_setup.R"))

# 1 - validation ####
#-------------------#

# extraction set with relevant class information attatched
extr = readRDS(file.path(envrmt$model_training_data, "extract_merge.RDS"))



for (i in c("main", "diverse")) {
  
  validation_aoa(extr,
                 model = i, 
                 idCol = "FAT__ID", 
                 responseCol = "BAGRu",
                 FID = sf::read_sf(file.path(envrmt$FID, "Trainingsgebiete.gpkg"))
  )
   print(paste("Finished validation for model: ", i)) 
} # end for loop



# 1.1 - Validation for successional stages ####
#---------------------------------------------#


for (i in c("Bu", "Fi", "Ei", "Dou", "Lä", "Ki", "Lbk", "Lbl")) {
  validation_aoa(extr = extr,
             model = paste0("quality_", i), 
             idCol = "FAT__ID", 
             responseCol = "Quality",
             FID = sf::read_sf(file.path(envrmt$FID, "Trainingsgebiete.gpkg"))
             ) 
  
  print(paste("Finished confusion matrix for model: ", i))
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
lstFiles = list.files(file.path(envrmt$confusionmatrix),  pattern = glob2rx("quality*confusionmatrix.RDS"))

for (i in 1:length(lstFiles)) {
  
  cm <- readRDS(file.path(envrmt$confusionmatrix,lstFiles[[i]]))
  cm <- as.data.frame(cm$table)
  
  if (nlevels(cm$Observed) == 3) {
    cm$Observed <- as.character(cm$Observed)
    cm[grepl("Qua", cm$Observed), "Observed"] <- "Q"
    cm[grepl("Dim", cm$Observed), "Observed"] <- "D"
    cm[grepl("Rei", cm$Observed), "Observed"] <- "M"
    
    cm$Predicted <- as.character(cm$Predicted)
    cm[grepl("Qua", cm$Predicted), "Predicted"] <- "Q"
    cm[grepl("Dim", cm$Predicted), "Predicted"] <- "D"
    cm[grepl("Rei", cm$Predicted), "Predicted"] <- "M"
  } else {
    cm$Observed <- as.character(cm$Observed)
    cm[grepl("Dim", cm$Observed), "Observed"] <- "D"
    cm[grepl("Rei", cm$Observed), "Observed"] <- "M"
    
    cm$Predicted <- as.character(cm$Predicted)
    cm[grepl("Dim", cm$Predicted), "Predicted"] <- "D"
    cm[grepl("Rei", cm$Predicted), "Predicted"] <- "M"
  }

cm$Observed <- as.factor(cm$Observed)
cm$Predicted <- as.factor(cm$Predicted)

if (nlevels(cm$Observed) == 3) {
  cm$Observed <- factor(cm$Observed,levels = c("Q", "D", "M"))
  cm$Predicted <- factor(cm$Predicted,levels = c("M",  "D","Q"))
} else {
  cm$Observed <- factor(cm$Observed,levels = c("D", "R"))
  cm$Predicted <- factor(cm$Predicted,levels = c(  "R",  "D"))
}

# Name of plot
modelName = gsub("quality_", "", lstFiles[[i]])
modelName=  gsub("_confusionmatrix.RDS", "", modelName)


plot_succession = successional_stages_cm(cm)
ggsave(plot = plot_succession, path = file.path(envrmt$illustrations), 
       filename = paste0(modelName, "_confusionmatrix.png"),
       width = 10,
       height = 7,
       dpi = 400)
} # end for loop

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

# 5.1 successional stages ####
#----------------------------#



var_imp = variable_importance(modelList = list.files(file.path(envrmt$models), pattern = "quality", full.names = TRUE),
                              plotNames = c("Beech", "Douglas fir", "Oak", "Spruce", "Pine",
                                            "Larch", "short-lived DT", "long-lived DT")
                              )




# save image
successional = grid.arrange(Beech, `Douglas fir`, Larch, `long-lived DT`, Oak, Pine, `short-lived DT`, Spruce, nrow = 4, ncol =2)

ggsave(filename = file.path(envrmt$illustrations, "variable_importance_successional.png"),
       plot = successional, 
       width = 8,
       height = 12,
       limitsize = FALSE,
       device = png())



