
myextent = sf::read_sf(file.path(envrmt$border, "Landesgrenze_RLP.shp"))
myextent = sf::st_transform(myextent, "epsg:25832")
myextent = sf::st_buffer(myextent, 200)

# 1 # summer 20m ####
#-------------------#

# setup sentinel retrieval object
out_paths_1 <- sen2r::sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  online = TRUE,
  extent = myextent,
  extent_name = "RLP_summer_20_part1",
  timewindow = c(as.Date("2019-06-24"), as.Date("2019-06-24")),
  list_prods = c("BOA"),
  mask_type = "cloud_and_shadow",
  max_mask = 10,
  path_l2a = file.path(envrmt$summer, "safe/"), # folder to store downloaded SAFE
  server = "scihub",
  preprocess = TRUE,
  sen2cor_use_dem = TRUE,
  max_cloud_safe = 10,
  overwrite = TRUE,
  res_s2 = "20m",
  proj = "+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ",
  s2tiles_selected = c("32UMV", "32UMA"),
  path_out =  envrmt$summer # folder to store downloaded research arec cutoff
)



# setup sentinel retrieval object
out_paths_1 <- sen2r::sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  online = TRUE,
  extent = myextent,
  extent_name = "RLP_summer_20_part2",
  timewindow = c(as.Date("2019-06-27"), as.Date("2019-06-27")),
  list_prods = c("BOA"),
  mask_type = "cloud_and_shadow",
  max_mask = 10,
  path_l2a = file.path(envrmt$summer, "safe/"), # folder to store downloaded SAFE
  server = "scihub",
  preprocess = TRUE,
  sen2cor_use_dem = TRUE,
  max_cloud_safe = 10,
  overwrite = TRUE,
  res_s2 = "20m",
  proj = "+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ",
  s2tiles_selected = c("31UGR","32ULA", "32ULB", "32ULV", "32UMB"),
  path_out =  envrmt$summer # folder to store downloaded research arec cutoff
)



# 2 - winter 10 m ####
#--------------------#

out_paths_1 <- sen2r::sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  online = TRUE,
  extent = myextent,
  extent_name = "RLP_winter_20_part1",
  timewindow = c(as.Date("2019-02-27"), as.Date("2019-02-27")),
  list_prods = c("BOA"),
  mask_type = "cloud_and_shadow",
  max_mask = 10,
  path_l2a = file.path(envrmt$winter, "safe/"), # folder to store downloaded SAFE
  server = "scihub",
  preprocess = TRUE,
  sen2cor_use_dem = TRUE,
  max_cloud_safe = 10,
  overwrite = TRUE,
  res_s2 = "20m",
  proj = "+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ",
  s2tiles_selected = c("31UGR", "32ULA", "32ULB", "32ULV", "32UMB"),
  path_out =  envrmt$winter # folder to store downloaded research arec cutoff
)



# setup sentinel retrieval object
out_paths_1 <- sen2r::sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  online = TRUE,
  extent = myextent,
  extent_name = "RLP_winter_20_part1",
  timewindow = c(as.Date("2019-02-24"), as.Date("2019-02-24")),
  list_prods = c("BOA"),
  mask_type = "cloud_and_shadow",
  max_mask = 10,
  path_l2a = file.path(envrmt$summer, "safe/"), # folder to store downloaded SAFE
  server = "scihub",
  preprocess = TRUE,
  sen2cor_use_dem = TRUE,
  max_cloud_safe = 10,
  overwrite = TRUE,
  res_s2 = "20m",
  proj = "+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ",
  s2tiles_selected = c("32UMA", "32UMV"),
  path_out =  envrmt$summer # folder to store downloaded research arec cutoff
)




