#' @name 014_table_metadata.R
#' @docType function
#' @param 
#' @return 


table_metadata = function(lstYaml) {
  
  
  # create table with metadata from yaml file
  df <- NULL
  for (i in lstYaml) {
    data <- read_yaml(i, as.named.list = TRUE)
    data <- yaml::yaml.load(data)
    
    newCol <- data.frame (Model  = data$Name,
                          No_tr_pol = data$`Number of training polygons`,
                          No_tr_pix_class = data$`Number of training pixel per class`[[1]],
                          No_tr_pix = sum(unlist(data$`Number of training pixel per class`)),
                          No_val_pol = data$`Number of validation polygons`,
                          No_val_pix = sum(unlist(data$`Number of validation pixel per class`))
    )
    df = rbind(df, newCol)
  }
  
  # rename colum names of table
  
  column = c("Model", 
             "No_tr_pol", 
             "No_tr_pix_class",
             "No_tr_pix",
             "No_val_pol", 
             "No_val_pix")
  label =  c( "Model", 
              "Number of training polygons",
              "Number of training pixel per class",
              "Number of training pixel",
              "Number of validation polygons",
              "Number of validation pixel")
  
  cols_list = as.list(label) %>% purrr::set_names(column)
  
  df %>%
    gt() %>%
    tab_style(
      style = list(
        cell_borders(
          sides = "left",
          color = "black",
          weight = px(3)
        )
      ),
      locations = list(
        cells_body(
          columns = c(No_tr_pol)
        )
      )
    ) %>%
    tab_style(
      style = list(
        cell_borders(
          sides = "bottom",
          color = "black",
          weight = px(3)
        )
      ),
      locations = list(
        cells_column_labels(
          columns = gt::everything()
        )
      )
    )  %>%
    cols_label(.list = cols_list)%>%
    gt::opt_row_striping(row_striping = TRUE)
  
} # end of function