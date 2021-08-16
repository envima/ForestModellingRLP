library(tidyverse)
library(gt)


model = readRDS("D:/forest_modelling/ForestModellingRLP/data/validation/meta_classes_diverse_confusionmatrix.RDS")
val_cm = model$table

test = as.data.frame.matrix(val_cm) 
d <- cbind(rownames(test), data.frame(test, row.names=NULL))
colnames(d)[1] <- "Class"
cn <- colnames(d)[-1]

d %>%
  gt()  %>%
  # colour the confusion matrix
  data_color(
    columns = c(cn),
    colors = "viridis"#scales::col_numeric(
      # Using a function from paletteer to generate a vector of colors
      # Note that you need to wrap paletteer_d outputs in as.character()
      #palette = as.character(paletteer::paletteer_d("ggsci::red_material", n = 5)),
      # Domain is from scales::col_numeric
      # Domain = The possible values that can be mapped
      # We don't HAVE to set a range for this since
      # we're using it inside data_color()
      #domain = NULL
    )
  ) %>% # end data_color
  # align all values in the center exept for the first column
  cols_align(
    align = c("center"),
    columns = cn
  ) %>% # end cols_align
  # create a bold line between column class and first value column
  tab_style(
    style = list(
      cell_borders(
        sides = "left",
        color = "black",
        weight = px(2)
      )
    ),
    locations = list(
      cells_body(
        columns = c(Bu)
      )
    )
  ) %>% # end tab style
  # We use tab_style() to change style of cells
  # cell_borders() provides the formatting
  # locations tells it where
  # Add black borders to the bottom of all the column labels
  tab_style(
    style = list(
      cell_borders(
        sides = "bottom",
        color = "black",
        weight = px(2)
      )
    ),
    locations = list(
      cells_column_labels(
        columns = gt::everything()
      )
    )
  )  %>% # end tap_style
 # tab_row_group(label, 
  #             rows = everything(), 
   #            id = label
    #            )# %>%
 # tab_spanner(label,
  #            columns = cn, 
   ##           id = label, 
     #         gather = TRUE)
