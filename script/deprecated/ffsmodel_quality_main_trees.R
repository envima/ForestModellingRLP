##37677
## Modelling of the main tree classes for RLP

rm(list=ls())


library(caret)
library(foreach)
library(doParallel)
library(CAST)
library(randomForest)

## choose model response
response_type<-"meta_classes_main_trees"

# load modelling data
pred_resp<-readRDS(paste0("data/modelling/", response_type, ".RDS"))


### Initialise Leave-Location out cv
## Main difference in the modelling strategy: we combine multiple location in the folds
# sample a ten fold cv stratified after the main tree species (BAGRu)
# spacevar = "FAT__ID" divides the polygon IDs into different folds
# CAST version 0.4.2
indices <- CreateSpacetimeFolds(pred_resp, spacevar = "FAT__ID", k=10, class = "BAGRu")



### Initialize Modelling

set.seed(10)
ctrl <- trainControl(method="cv",index = indices$index,
                     savePredictions=TRUE )



# no model tuning
tgrid <- expand.grid(.mtry = 2,
                     .splitrule = "gini",
                     .min.node.size = 1)


predictors <- pred_resp[,2:145]
response <- factor(pred_resp$BAGRu)

#run ffs model with Leave Location out CV
# we use randomForest now, ranger defaults to num.threads = number of CPUs available
# we dont want to mess with double parallel
cl <- makeCluster(10)
registerDoParallel(cl)
set.seed(10)
ffsmodel <- ffs(predictors,response, metric="Kappa", method="rf",
                trControl=ctrl, importance = TRUE ,tuneLength = 1, ntree = 50)
ffsmodel
varImp(ffsmodel)
saveRDS(ffsmodel,paste0(response_type,"_ffs.RDS"))

stopCluster(cl)
#