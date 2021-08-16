library(gt)

df3 <- data.frame (Model  = m,
                  No = meta$`Number of training polygons`,
                  No_tr_pix_class = c(table(training_set$BAGRu)[[1]]),
                  No_val_pol = meta$`Number of validation polygons`,
                  No_val_pix = sum(unlist(meta$`Number of validation pixel per class`))
)


#--------------------------

column = c("Model", 
           "No_tr_pol", 
           "No_tr_pix_class",
           "No_val_pol", 
           "No_val_pix")
label =  c( "Model", 
            "Number of training polygons",
            "Number of training pixel per class",
            "Number of validation polygons",
            "Number of validation pixel")

  cols_list = as.list(label) %>% purrr::set_names(column)
  
  df_main %>%
    gt() %>%
     
    ##########################
  ### This section changed
  ##########################
  # We use tab_style() to change style of cells
  # cell_borders() provides the formatting
  # locations tells it where
  # add a border to left of the Total column
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
    # We use tab_style() to change style of cells
    # cell_borders() provides the formatting
    # locations tells it where
    # Add black borders to the bottom of all the column labels
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

