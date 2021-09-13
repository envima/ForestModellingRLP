#' @name 00X_download_hansen.R
#' @borderFileName = 
#' @return SpatRaster with treeCover, gain, loss, for 2018
#'
#'
#'
#'


download_hansen = function(borderFilePath = file.path(envrmt$border, "border_buffer_200m.gpkg")){
  
  # Define an image.
  img <- ee$Image("UMD/hansen/global_forest_change_2018_v1_6")$
    select(c('treecover2000', 'loss', 'gain'))
  
  
  
  # Define an area of interest.
  region  = sf::read_sf(borderFilePath) %>%
    sf::st_transform("EPSG:32632") %>%
    rgee::sf_as_ee()
  # transform to EarthEngine Object: Geometry
  region = region$geometry()$bounds()
  
  
  ## download via google drive
  img_02 <- ee_as_raster(
    image = img,
    region = region,
    via = "drive"
  )
  
  for (i in 1:raster::nlayers(img_02)){
    r = img_02[[i]]
    n = names(r)
    raster::writeRaster(r, filename = file.path(envrmt$hansen, paste0(n, ".tif")), overwrite = TRUE)
    print(paste("Finished saving raster", n))
  }
  
}                    