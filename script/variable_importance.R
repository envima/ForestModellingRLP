###########################################################################
#                                                                         #
# name: variable_importance.R                                             #
# date: 07 05 2021                                                        #
# data: all ffs models for tree species and successional stages           #
# output: .png image with variable importance scaled from 0 to 100 for    #
#         each model                                                      #
#                                                                         #
###########################################################################

# 1 - set up & load data
#-----------------------

require(tidyverse)
require(gridExtra)
setwd("D:/forest_modelling/ForestModellingRLP/data/models/")

modelList = list.files(pattern = ".RDS")
modelList = modelList[-1]
plotNames = c("Beech", "Douglas fir", "Larch", "short-lived DT", "long-lived DT", "Oak", "Pine", "Spruce")



# 2 - plot variable importance for each successional model and save image
#------------------------------------------------------------------------

for (i in 1:length(modelList)) {
model = readRDS(modelList[i])

# create dataframe with variable importance
varperf <-max(model$selectedvars_perf)-model$selectedvars_perf
varperf <- scales::rescale(varperf, to = c(0, 100))
df <- data.frame(imp = prepend(varperf, varperf[1]))
df2 <- df %>% 
  tibble::rownames_to_column() %>% 
  dplyr::rename("variable" = rowname) %>% 
  dplyr::mutate(variable = model$selectedvars) %>%
  arrange(imp) %>%
  mutate(variable=factor(variable, levels=variable))

# assign title to dataframe to use facet_grid in ggplot() function
df2$title <- plotNames[i] 

# plot
assign(plotNames[i], ggplot2::ggplot(df2) +
          geom_segment(aes(x = variable, y = 0, xend = variable, yend = imp)) +
          geom_point(aes(x = variable, y = imp), show.legend = F) +
          ylab ("")+
          xlab("")+
          coord_flip() +
          theme_bw() +
          facet_grid(. ~ title)
) # end assign
} # end for-loop


# save image
successional = grid.arrange(Beech, `Douglas fir`, Larch, `long-lived DT`, Oak, Pine, `short-lived DT`, Spruce, nrow = 4, ncol =2)


ggsave(filename = paste0("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/images/variable_importance/successional_stages.png"),
       plot = successional, 
       width = 8,
       height = 12,
       limitsize = FALSE,
       device = png())


# 3 - plot variable importance formain and diverse model and save image
#------------------------------------------------------------------------

# load main and diverse tree species model
mainModel = readRDS("meta_classes_main_trees_ffs.RDS")
diverseModel = load("meta_classes_diverse_ffs.RData")
diverseModel = ffsmodel
rm(ffsmodel, mod)
mainDiverse = list(diverseModel, mainModel)
plotNames = c("Diverse", "Main")


# 3.1 - plot and save main and diverse Model 
#-------------------------------------------

for (i in 1:length(mainDiverse)) {
  model = mainDiverse[[i]]
  
  # create dataframe with variable importance
  varperf <-max(model$selectedvars_perf)-model$selectedvars_perf
  varperf <- scales::rescale(varperf, to = c(0, 100))
  df <- data.frame(imp = prepend(varperf, varperf[1]))
  df2 <- df %>% 
    tibble::rownames_to_column() %>% 
    dplyr::rename("variable" = rowname) %>% 
    dplyr::mutate(variable = model$selectedvars) %>%
    arrange(imp) %>%
    mutate(variable=factor(variable, levels=variable))
  
  # assign title to dataframe to use facet_grid in ggplot() function
  df2$title <- plotNames[i] 
  
  # plot
  assign(plotNames[i], ggplot2::ggplot(df2) +
           geom_segment(aes(x = variable, y = 0, xend = variable, yend = imp)) +
           geom_point(aes(x = variable, y = imp), show.legend = F) +
           ylab ("")+
           xlab("")+
           coord_flip() +
           theme_bw() +
           facet_grid(. ~ title)
  ) # end assign
} # end for-loop


# save image
models = grid.arrange(Main, Diverse, nrow = 2, ncol =1)


ggsave(filename = paste0("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/images/variable_importance/tree_species_models.png"),
       plot = models, 
       width = NA,
       height = 10,
       limitsize = FALSE,
       device = png())
