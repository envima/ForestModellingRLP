##37677

rm(list=ls())


library(caret)
library(foreach)
library(doParallel)
library(CAST)
library(ranger)
library(randomForest)
##data
response_type<-"meta_classes_main_trees"

pred_resp<-readRDS(paste0("data/modelling/", response_type, ".RDS"))
summary_data<-readRDS("data/modelling/summary_train_data.RDS")




#k <- summary_data$number_of_distinct_locations[summary_data$data_set==response_type][1] # Anzahl der BufferID's pro Landnutzungsklasse
#uniqueSites <- unique(pred_resp[,c("FAT__ID","BAGRu")])
#uniqueSites$ID <- 1:nrow(uniqueSites)


# create folds with one location for each tree species
#folds <- createFolds(uniqueSites$BAGRu,k,list=TRUE)

#for (i in 1:length(folds)){
#  uniqueSites$Group[uniqueSites$ID%in%folds[[i]]] <- paste0("Group_",i)
#}

#pred_resp <- merge(pred_resp,uniqueSites,by.x="FAT__ID",by.y="FAT__ID")

### Index erstellen:

indices <- CreateSpacetimeFolds(pred_resp, spacevar = "FAT__ID",k=10, class = "BAGRu")
#table(pred_resp$BAGRu[indices$indexOut[[5]]],pred_resp$FAT__ID[indices$indexOut[[5]]] )

####



set.seed(10)
ctrl <- trainControl(method="cv",index = indices$index,
                     savePredictions=TRUE )
#load and prepare dataset:

#create folds for Leave Location Out Cross Validation:

tgrid <- expand.grid(.mtry = 2,
                     .splitrule = "gini",
                     .min.node.size = 1)

predictors <- pred_resp[,2:145]
response <- factor(pred_resp$BAGRu)

#run ffs model with Leave Location out CV
cl <- makeCluster(10)
registerDoParallel(cl)
set.seed(10)
ffsmodel <- ffs(predictors,response, metric="Kappa", method="rf",
                trControl=ctrl, importance = TRUE ,tuneLength =  1, ntree = 50)

mod <- train(x = predictors, y = response, method = "ranger", metric="Kappa", 
             trControl=ctrl, importance="impurity", tuneGrid = tgrid, num.trees = 50)
mod

ffsmodel

saveRDS(ffsmodel,paste0(response_type,"_ffs.RDS"))


stopCluster(cl)
#