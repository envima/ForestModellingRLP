#' @name 00X_download_hansen.R
#' @borderFileName = 
#' @return SpatRaster with treeCover, gain, loss, for 2018
#'
#'
#'
#'


download_hansen = function(borderFilePath = file.path(envrmt$border, "border_buffer_200m.gpkg"), 
                           outPath = file.path(envrmt$hansen, "/hansen.tif")){
  
  # Define an image.
  img <- ee$Image("UMD/hansen/global_forest_change_2018_v1_6")$
    select(c('treecover2000', 'loss', 'gain'))$
    reproject("EPSG:25832")
  
  
  
  # Define an area of interest.
  region  = sf::read_sf(borderFilePath) %>%
    sf::st_transform("EPSG:25832") %>%
    rgee::sf_as_ee()
  # transform to EarthEngine Object: Geometry
  region = region$geometry()$bounds()
  img = img$clip(region)
  
  
  task_img <- ee_image_to_drive(
    image = img,
    folder = "rgee_backup",
    scale = 20,
    region = region,
    maxPixels = 213152170
  )
  
  task_img$start()
  ee_monitoring(task_img)
  # Move results from Drive to local
  ee_drive_to_local(task = task_img, dsn = file.path(envrmt$hansen, "/hansen.tif"))
  
}                    