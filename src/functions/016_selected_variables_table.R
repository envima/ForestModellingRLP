#' @name 016_selected_variables_table.R
#' @docType function
#' @description 
#' @param 
#' @param 
#' @return 



lstModels = list.files(file.path(envrmt$models), pattern = ".RDS")
varNames = read.csv(file.path(envrmt$selected_variables, "variables_full_names.csv"), sep = ";")
library(dplyr)

#-------------
for (i in 1:length(lstModels)) {
  n = gsub("_ffs.RDS","", lstModels[i])
  n = gsub("quality_", "", n)
  mod = readRDS(file.path(envrmt$models, lstModels[i]))
  selectedvars = mod$selectedvars
  df2 = data.frame(Name = selectedvars,
                   model = 1)
  colnames(df2)[2] <- n
  if (i == 1) {
    df <- df2
  } else {
    df = merge(df,df2, by.x= "Name", by.y = "Name", all.x = TRUE, all.y = TRUE)
  }
} # end for loop

rm(df2,mod,varNames,i,lstModels,n,selectedvars)

# calculate how often a variable occures:
df$Frequency = rowSums(df[,c(2:10)], na.rm = TRUE)

df_new = merge(df, varNames, by.x = "Name", by.y = "Index")

df_new = df_new %>% 
  arrange(desc(Frequency), Type) %>%
  relocate(Description, .after = Name)


# Plot table
#-------------------------

df_new %>% 
  gt() %>% 
  #color lidar rows
  tab_style(
    style = list(
      cell_fill(color = "#FDE725FF")
    ),
    locations = cells_body(
     # columns = vars(V1, V2), # not needed if coloring all columns
      rows = Type == "lidar")
  ) %>%
  # color index rows
  tab_style(
    style = list(
      cell_fill(color = "#33638DFF")
    ),
    locations = cells_body(
      # columns = vars(V1, V2), # not needed if coloring all columns
      rows = Type == "index")
  ) %>%
  #color band rows
  tab_style(
    style = list(
      cell_fill(color = "#73D055FF")
    ),
    locations = cells_body(
      # columns = vars(V1, V2), # not needed if coloring all columns
      rows = Type == "band")
  ) %>%
  # missing values
  fmt_missing(columns = everything(),rows = everything(), missing_text = "-")

 



