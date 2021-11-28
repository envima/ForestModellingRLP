fid = sf::read_sf(file.path(envrmt$FID, "test.gpkg"))

fid$LLO_ID <- NA
fid = fid[c("FAT__ID", "BAGRu", "geom", "LLO_ID", "Phase", "proz")]
unique(fid$BAGRu)
for (cl in unique(fid$BAGRu)) {
  group = fid %>% filter(BAGRu == cl)
  
  for(p in 1:nrow(group)) {
    group = fid %>% filter(BAGRu == cl)
    referencePolygon = group[p,]
    #  referencePolygon = group %>% filter(FAT__ID == 501349)
    
    referencePolygon = sf::st_buffer(referencePolygon, 10)
    close2pol = sf::st_intersects(referencePolygon, group, sparse = FALSE)
    group$close <- as.character(close2pol)
    df = group %>% filter(close == "TRUE")
    
    
    if (all(is.na(df$LLO_ID))) {
      ids <- referencePolygon$FAT__ID
    } else {
      ids =unique(df$LLO_ID)
    }
    
    
    
    
    ids = na.omit(ids) 
    
    
    if(length(ids) == 1 && ids %in% unique(df$FAT__ID)) {
      fid <- fid %>% mutate(LLO_ID = case_when( fid$FAT__ID %in% df$FAT__ID ~ as.numeric(ids),
                                                
                                                TRUE ~ as.numeric(LLO_ID)
      ))
    } 
    
    if(length(ids)==2 | !(ids %in% unique(df$FAT__ID))) {
      x <- filter(fid, fid$LLO_ID == ids[1] | fid$LLO_ID == ids[2] )
      fid <- fid %>% mutate(LLO_ID = case_when( fid$FAT__ID %in% df$FAT__ID ~ ids[1],
                                                fid$FAT__ID %in% x$FAT__ID  ~ ids[1],
                                                TRUE ~ as.numeric(LLO_ID)
      ))
    }
    
    
   # if(length(ids)==3){
    #  fid <- fid %>% mutate(LLO_ID = case_when( fid$FAT__ID %in% df$FAT__ID ~ ids[1],
     #                                           fid$FAT__ID %in% filter(fid, fid$LLO_ID == ids[1] | fid$LLO_ID == ids[2]  | fid$LLO_ID == ids[3])  ~ ids[1],
      #                                          TRUE ~ as.numeric(LLO_ID)
  #    ))
   # }
    
    
    
    
    # fid$LLO_ID <- fid$new
    print(p)
    
    
  }
  print(paste("finished class: ", cl))
}
sf::write_sf(fid, file.path(envrmt$FID, "test_LLO_ID.gpkg"))

