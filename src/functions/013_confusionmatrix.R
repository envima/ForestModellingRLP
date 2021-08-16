#' @name 012_confusionmatrix.R
#' @docType function
#' @description 
#' @param caretConfMatr
#' @return confMatr


confusionMatrix_ggplot <- function(caretConfMatr) {
  
  cm <- as.data.frame((caretConfMatr$table))
  
  # values as percentage
  sum_obser = aggregate(cm$Freq, by=list(Category= cm$Observed), FUN=sum)
  for (i in 1:nrow(cm)) {
    cm$Perc[i] <- round((cm$Freq[i] / filter(sum_obser, Category == cm$Observed[[i]])$x)
                        *100,2)
  }
  
  # divide in True Positive and other
  cm$Scale = 1
  for (i in 1:nrow(cm)) {
    if (cm[i,]$Observed == cm[i,]$Predicted) {
      cm[i,]$Scale <- 0
    } # end if
  } # end for loop
  
  cm = cm %>% 
    mutate(Perc1 = replace(Perc, Scale == 0, NA))%>% 
    mutate(Perc2 = replace(Perc, Scale == 1, NA))
  
  
  # plot
  
  confMatr = ggplot(data = cm, aes(x = Predicted , y =  Observed))+
    geom_tile(aes(x = Predicted , y =  Observed, fill = Perc1)) +
    scale_fill_distiller(palette = "Reds",
                         na.value = "transparent",
                         guide = "none",
                         direction = 1) +
    theme_light() +
    
    ggnewscale::new_scale_fill()+
    geom_tile(aes(x = Predicted , y =  Observed, fill = Perc2)) +
    scale_fill_distiller(palette = "Greens",
                         na.value = "transparent",
                         guide = "none",
                         direction = 1) +
    #Add text
    geom_text(aes(label = paste(Perc,"%")), color = 'black') +
    theme_light()
  
  return(confMatr)
  
} # end confucionMatrix_ggplot function
