cm <- readRDS("D:/forest_modelling/ForestModellingRLP/data/validation/quality_beech_confusionmatrix.RDS")
cm <- as.data.frame(cm$table)

cm$Observed <- factor(cm$Observed,levels = c("Bu_Qua", "Bu_Dim", "Bu_Rei"))
cm$Predicted <- factor(cm$Predicted,levels = c(  "Bu_Rei",  "Bu_Dim","Bu_Qua"))

#############

library(RColorBrewer)
library(ggplot2)

ggplot(cm, aes(fill=Predicted, y=Freq, x=Observed)) + 
  geom_bar(position="fill", stat="identity", colour = "grey20") +
  scale_fill_viridis_d()  +
  coord_flip() +
  ylab("Percent")+
  
  ggnewscale::new_scale_fill() +
  geom_bar(aes(fill = Predicted,
               size = (Predicted == "Bu_Qua" & Observed == "Bu_Qua")),
           colour = "black", 
           #width = .6,
           position="fill", 
           stat="identity",
           alpha=0) +
  scale_size_manual(values = c(0, 1.2),
                    guide = "none") +
  
  
  ggnewscale::new_scale_fill() +
  geom_bar(aes(fill = Predicted,
               size = (Predicted == "Bu_Rei" & Observed == "Bu_Rei")),
           colour = "black", 
           #width = .6,
           position="fill", 
           stat="identity",
           alpha=0) +
  scale_size_manual(values = c(0, 1.2),
                    guide = "none") +
  
  ggnewscale::new_scale_fill() +
  geom_bar(aes(fill = Predicted,
               size = (Predicted == "Bu_Dim" & Observed == "Bu_Dim")),
           colour = "black", 
           #width = .6,
           position="fill", 
           stat="identity",
           alpha=0) +
  scale_size_manual(values = c(0, 1.2),
                    guide = "none") 
  
#------------------------------







  geom_bar(
    aes(fill = Predicted, size = (Predicted == "Bu_Qua" & Observed == "Bu_Qua")),
    color = "black", width = .5) + 
  scale_size_manual(values = c(0, 1.2),
                    guide = "none")


############



ggplot(mpg, aes(class)) +  
  
  geom_bar(
    aes(fill = drv, size = (drv == "4" & class == "compact")),
    color = "black", width = .5) + 
  scale_size_manual(values = c(0, 1.2),
                    guide = "none")




