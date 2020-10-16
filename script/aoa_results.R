library(raster)


aoa_fl = "data/aoa_diverse/aoa_beech_diverse.grd"

aoa = raster(aoa_fl, 2)
aoa = raster::readAll(aoa)

table(getValues(aoa))
