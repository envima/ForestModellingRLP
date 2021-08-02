##37677

rm(list=ls())


library(caret)
library(foreach)
library(doParallel)
library(CAST)

##data
response_type<-"quality_diverse"

pred_resp<-readRDS(paste0("data/modelling/", response_type, ".RDS"))

summary_data<-readRDS("data/Trainingsgebiete_RLP/summary_train_data.RDS")




k <- summary_data$number_of_distinct_locations[summary_data$data_set==response_type][1] # Anzahl der BufferID's pro Landnutzungsklasse
uniqueSites <- unique(pred_resp[,c("FAT__ID","Quality")])
uniqueSites$ID <- 1:nrow(uniqueSites)
folds <- createFolds(uniqueSites$Quality,k,list=TRUE)
for (i in 1:length(folds)){
  uniqueSites$Group[uniqueSites$ID%in%folds[[i]]] <- paste0("Group_",i)
}
pred_resp <- merge(pred_resp,uniqueSites,by.x="FAT__ID",by.y="FAT__ID")
### Index erstellen:

indices <- CreateSpacetimeFolds(pred_resp,spacevar = "Group",k=k)


####

cl <- makeCluster(k)
registerDoParallel(cl)

set.seed(10)
ctrl <- trainControl(method="cv",index = indices$index,
                     savePredictions=TRUE )
#load and prepare dataset:

#create folds for Leave Location Out Cross Validation:

tgrid <- expand.grid(.mtry = seq(2, 32, by=3),
                     .splitrule = "gini",
                     .min.node.size = 1)

predictors <- pred_resp[,2:145]
response <- factor(pred_resp$Quality.x)

#run ffs model with Leave Location out CV
set.seed(10)
ffsmodel <- ffs(predictors,response,metric="Kappa",method="ranger",
                trControl=ctrl, importance="impurity", tuneGrid = tgrid)
ffsmodel

saveRDS(ffsmodel,paste0(response_type,"_ffs.RDS"))


stopCluster(cl)
#