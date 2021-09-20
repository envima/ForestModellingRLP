#' @name XXX_download_sentinel_gee.R
#' @docType function
#' @description 
#' @param startdate = "2019-06-21" 
#' @param enddate = "2019-06-30"
#' @param borderFilePath = file.path(envrmt$border, "border_buffer_200m.gpkg")
#' @param MaxCloud = 2
#' @param outfilePath = file.Path(envrmt$summer)
#' @return 


download_sentinel = function(startdate = "2019-06-29", 
                             enddate = "2019-06-30", 
                             borderFilePath = file.path(envrmt$border, "border_buffer_200m.gpkg"),
                             MaxCloud = 5,
                             outfilePath = file.path(envrmt$summer, "/")) {
  
  # Define an image Collection of sentinel-2 Images at Level 2-A
  # More info at: https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR
  img <- ee$ImageCollection("COPERNICUS/S2_SR") 
  
  # get crs of Image Collection
  #img_crs = img$getInfo()$features[[1]]$bands[[1]]$crs 
  
  
  # Define an area of interest.
  region  = sf::read_sf(borderFilePath) %>%
    sf::st_transform("EPSG:25832") %>%
    rgee::sf_as_ee()
  # transform to EarthEngine Object: Geometry
  region = region$geometry()$bounds()
  
  # filter imagecollection by date and  cloud cover
  
  img = img$filter(ee$Filter$lte("CLOUDY_PIXEL_PERCENTAGE", MaxCloud))$
    filterDate(startdate, enddate)$
    filterBounds(region)$
    map(function(x) x$reproject("EPSG:25832"))
  # Number and dates of selected images
  tiles = ee_get_date_ic(img)
  print(tiles)
  
  # create an Image and get bandnames
  selected_images = img$mosaic()
  band_names = selected_images$bandNames()$getInfo()   
  band_names = band_names[1:12]
  #print(paste("Download the following band: ", band_names))
  # select bands 
  img = img$select(band_names)
  
  
  img2 = img$mosaic()$reproject("EPSG:25832")
  
  #continue = readline("Do you want to download all the sentinel tiles listed above?[TRUE/FALSE]")  
  
  #if (continue == TRUE) {
    #img$getInfo()
    
    
   # img_02 = ee_imagecollection_to_local(
    #  ic = img,
     # dsn = outfilePath,
      #region = region,
      #crs = 'EPSG:25832',
      #via = "drive",
      #container = "rgee_backup",
      #maxPixels = 1e+09,
      #lazy = FALSE,
      #public = FALSE,
      #add_metadata = TRUE,
      #timePrefix = TRUE,
      #quiet = FALSE,
      #scale = 20
    #)
  #} # end if 
  #if (continue == FALSE) {
    #------------------------
  #  continue = readline("Do you want to download one specific tile?[y/n]")  
   # if (continue == "y" | continue == "Y") {
    #  nTile = readline("Which one?[number of tile in list above]")
      
      #img2 = img$filterMetadata("DATATAKE_IDENTIFIER" , "equals", "20190224T103019_20190224T103021_T32UNV")
     # img2 =ee$Image(tiles$id[[as.integer(nTile)]])$reproject("EPSG:25832")$select(band_names)
      
      
      task_img <- ee_image_to_drive(
        image = img2,
        folder = "rgee_backup",
        scale = 20,
        region = region,
        maxPixels = 213152170
      )
      
      task_img$start()
      ee_monitoring(task_img)
      # Move results from Drive to local
      ee_drive_to_local(task = task_img, dsn = outfilePath)
      
    }
 # }
#}