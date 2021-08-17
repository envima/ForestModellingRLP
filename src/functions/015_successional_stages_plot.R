#' @name 015_successional_stages_plot.R
#' @docType function
#' @description 
#' @param cm
#' @return p ggplot




successional_stages_cm <- function(cm) {
  
  p = ggplot(cm, aes(fill=Predicted, y=Freq, x=Observed)) + 
    geom_bar(position="fill", stat="identity", colour = "grey20") +
    scale_fill_viridis_d()  +
    coord_flip() +
    ylab("Percent")
  
  lst = list()
  
  for (i in 1:nlevels(cm$Observed)) {
    
    stage = levels(cm$Observed)[i] 
    stage <- enquo(stage)
    
    lst[[i]] = geom_bar(aes(fill = Predicted,
                            size = (Predicted == !! stage & Observed == !! stage)),
                        colour = "black", 
                        #width = .6,
                        position="fill", 
                        stat="identity",
                        alpha=0)
    
  }# end for loop
  
  
  p = p+ ggnewscale::new_scale_fill() + 
    lst+
    scale_size_manual(values = c(0, 1.2),
                      guide = "none")
  
  
} # end of function
