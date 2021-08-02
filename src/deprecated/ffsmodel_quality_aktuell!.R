##37677

rm(list=ls())


library(caret)
library(foreach)
library(doParallel)
library(CAST)

##data
dat_lst<-list.files("data/modelling/", pattern="quality", full.names = TRUE)


for(i in dat_lst){

  
  response_type = gsub(".RDS", "",basename(i))
  
  print(response_type)
  pred_resp<-readRDS(i)
  ### Initialise Leave-Location out cv
  ## Main difference in the modelling strategy: we combine multiple location in the folds
  # sample a ten fold cv stratified after the main tree species (BAGRu)
  # spacevar = "FAT__ID" divides the polygon IDs into different folds
  # CAST version 0.4.2
  indices <- CreateSpacetimeFolds(pred_resp, spacevar = "FAT__ID", k=10, class = "Quality")

  
  
  ### Initialize Modelling
  
  set.seed(10)
  ctrl <- trainControl(method="cv",index = indices$index,
                       savePredictions=TRUE )
  
  
  
  # no model tuning
  tgrid <- expand.grid(.mtry = 2,
                       .splitrule = "gini",
                       .min.node.size = 1)



  predictors <- pred_resp[,2:145]
  response <- factor(pred_resp$Quality)

#run ffs model with Leave Location out CV
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

}
#