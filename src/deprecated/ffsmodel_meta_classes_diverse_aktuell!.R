##37677

rm(list=ls())

library(caret)
library(foreach)
library(doParallel)
library(CAST)
library(ranger)
library(telegram.bot)
library(randomForest)

bot <- Bot(token = readLines("token.txt"))
alert_chats <- c("-361124846")#,"-368020260")


##data
response_type<-"meta_classes_diverse"

pred_resp<-readRDS(paste0("data/modelling/", response_type, ".RDS"))

summary_data<-readRDS("data/Trainingsgebiete_RLP/summary_train_data.RDS")

indices <- CreateSpacetimeFolds(pred_resp, spacevar = "FAT__ID",k=10, class = "BAGRu")




####
ncores = 50

a <- Sys.info()
for(i in 1:length(alert_chats)){bot$send_message(chat_id = alert_chats[i],text = paste0("Initiated calculations for response type ",response_type,
                                                                                        " calculating on computer ", a[names(a)=="nodename"],
                                                                                        " on ", ncores, " cores "," by user ", a[names(a)=="user"], 
                                                                                        " I will alert you when calculations are finished."
))
}

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
set.seed(10)
cl <- makeCluster(ncores)
registerDoParallel(cl)

ffsmodel <- ffs(predictors,response, metric="Kappa", method="rf",
                trControl=ctrl, importance = TRUE ,tuneLength =  1, ntree = 50)
mod <- train(x = predictors, y = response, method = "ranger", metric="Kappa", 
             trControl=ctrl, importance="impurity", tuneGrid = tgrid, num.trees = 50)
mod
ffsmodel

stopCluster(cl)
save(mod,ffsmodel,paste0(response_type,"_ffs.RData"))
for(i in 1:length(alert_chats)){bot$send_message(chat_id = alert_chats[i],
                                                 text = paste0("Finished calculations for response type ",response_type,
                                                               " on computer ", a[names(a)=="nodename"], 
                                                               " initiated by user ", a[names(a)=="user"]
                                                 )
)
}

#