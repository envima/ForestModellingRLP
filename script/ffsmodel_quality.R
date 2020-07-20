##37677

rm(list=ls())


library(caret)
#library(foreach)
#library(doParallel)
library(CAST)

##data
dat_lst<-list.files("data/modelling/", pattern="quality", full.names = TRUE)

for(i in dat_lst){
response_type<- gsub(".RDS", "",i)
response_type<-gsub("data/modelling/", "",response_type)
print(response_type)
pred_resp<-readRDS(i)
dens_plots<-ddply(pred_resp,~Quality,summarise,number_of_distinct_locations=length(unique(FAT__ID)))




k <- dens_plots$number_of_distinct_locations[1] # Anzahl der BufferID's pro Landnutzungsklasse
print(k)
uniqueSites <- unique(pred_resp[,c("FAT__ID","BAGRu")])
uniqueSites$ID <- 1:nrow(uniqueSites)
folds <- createFolds(uniqueSites$BAGRu,k,list=TRUE)
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
response <- factor(pred_resp$BAGRu.x)

#run ffs model with Leave Location out CV
set.seed(10)
ffsmodel <- ffs(predictors,response,metric="Kappa",method="ranger",
                trControl=ctrl, importance="impurity", tuneGrid = tgrid)
ffsmodel

saveRDS(ffsmodel,paste0(response_type,"_ffs.RDS"))


stopCluster(cl)

}
#