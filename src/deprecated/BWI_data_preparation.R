# name: BWI_data_preparation.R
# date: 18.20.2020
# data: - go to: https://bwi.info/Download/de/BWI-Basisdaten/ACCESS2003/
#       - download "bwi20150320_alle_daten2012.zip"
#       - export spreadsheet "b3_bestock_baanteile" as csv file
#       - download shapefiles "ShapeFile_Tnr_INSPIRE_Poly1000.zip"
#
# further information:
# https://www.bundeswaldinventur.de/fileadmin/SITE_MASTER/content/Downloads/BWI_Methodenband_web.pdf

# 1 - set up ####
#----------------

library(sf)
setwd("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Bundeswaldinventur")


# 2 - tree species table ####
#---------------------------

# table tree species
B3_BA <- read.csv("2012/b3_bestock_baanteile.csv", header = TRUE, sep = ";")

# Filter by "Schicht" = 1 -> Hauptbestockung
B3_BA <- B3_BA[B3_BA$Schicht == 1,]

# new ID column + cleaning
B3_BA$ID <- as.character(paste0(B3_BA$ï..Tnr, "E", B3_BA$Enr))
B3_BA$AnteilBa <- gsub("\\,", ".", B3_BA$AnteilBa)

# Only BA with at least 80 % purity
B3_BA <- B3_BA[B3_BA$AnteilBa >= 0.8,]

# 2.1 - assignment of tree species groups #####
#-------------------------------------------

# All in RLP occurring tree species
BA <- read.csv("BWI_RLP_BA.csv", header = TRUE, sep = ";")

B3_BA <- merge(BA, B3_BA, by.x = "Nummer.BWI", by.y = "Ba")
rm (BA)
B3_BA <- subset(B3_BA, select = -c(Schicht, Herkunft, X, Bedeutung.BWI, Nummer.BWI ,WLT_P ,WLT_N ,WLT_H, natWG_P , natWG_N ,natWG_H ,BaLN ,BaFBa ,BaEU))

# 3 - Shapefiles BWI ####
#------------------------

BWI <- sf::read_sf("ShapeFile_Tnr_INSPIRE_Poly1000/Tnr_INSPIRE_Poly1000.shp") # shapefiles germany
border <- sf::read_sf("../Landesgrenze_RLP/border200mBuffer.shp") # border RLP
BWI <- sf::st_transform(BWI, crs = 32632) # change CRS to UTM 32N
RLP <- sf::st_intersection (BWI, border) # clip 

# remove all polygons that were cut at the border
RLP_border <- NULL
for (i in RLP$Tnr) {
  pol <- RLP[RLP$Tnr == i,]
  if (sf::st_area(pol) >= units::set_units(999197 ,"m^2")) {
    RLP_border <- rbind(RLP_border, pol)
  }
}
RLP <- RLP_border
rm(BWI, RLP_border, pol, i)

# remove polygons which haven´t been in BWI 3 2012
RLP <- RLP[RLP$Tnr %in% B3_BA$ï..Tnr,]


# 3.2 - create new polygons at the corners ####
#----------------------------------------------

# new polygon at each corner:
# cf.: https://bwi.info/Download/de/Methodik/Aufnahmeanweisung_BWI3.pdf P. 13; 
# Corner numbers: 1=A, 2=B, 3=C, 4=D
# 
# buffer around corners with dist = 10; cf. P. 15 Chapter: 2.5 Probekreise
rlp_polygons <- NULL
for (i in 1:nrow(RLP)) {
  
  pol <- RLP[i,]
  cord <- sf::st_bbox(pol)
  
  TE1 = st_buffer(st_sf(ID = as.character(paste0(pol$Tnr, "E1")), 
                        geom = st_sfc(st_point(c(cord[1], cord[2]))), 
                        crs = 32632), dist = 10)
  TE2 = st_buffer(st_sf(ID = as.character(paste0(pol$Tnr, "E2")), 
                        geom = st_sfc(st_point(c(cord[1], cord[4]))), 
                        crs = 32632), dist = 10)
  TE3 = st_buffer(st_sf(ID = as.character(paste0(pol$Tnr, "E3")), 
                        geom = st_sfc(st_point(c(cord[3], cord[4]))), 
                        crs = 32632), dist = 10)
  TE4 = st_buffer(st_sf(ID = as.character(paste0(pol$Tnr, "E4")), 
                        geom = st_sfc(st_point(c(cord[3], cord[2]))), 
                        crs = 32632), dist = 10)
  
  
  rlp_polygons <- rbind(TE1, TE2, TE3, TE4, rlp_polygons)
  print(i)
}
rm(pol, TE1, TE2, TE3, TE4, cord, i)


# 4 - merge BA and shapefiles
#----------------------------

B3_BA <- B3_BA[B3_BA$ID %in% rlp_polygons$ID,]

RLP <- merge(B3_BA, rlp_polygons, by.x = "ID", by.y = "ID")
sf::write_sf(RLP, "BWI_validation.shp")
