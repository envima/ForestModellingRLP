
### basic setup
# install/check from github

devtools::install_github("envima/envimaR")
devtools::install_github("gisma/uavRst")
devtools::install_github("r-spatial/link2GI")

packagesToLoad = c("lidR", "link2GI", "mapview", "raster", "rgdal", "rlas", "sp", "uavRst", "sf")

# Source setup script
require(envimaR)
rootDir = envimaR::alternativeEnvi(root_folder = "C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung",
                                   alt_env_id = "Computername",
                                   alt_env_value = "PCRZP",
                                   alt_env_root_folder = "F:/BEN/edu")


# Set project specific subfolders
projectDirList   = c("data/",                                 # local data folders
                     "data/summer/",
                     "data/winter/",
                     "data/hansen",
                     "data/indices/",
                     "data/Landesgrenze_RLP/",
                     "data/Exp_Shape_Wefl_UTM/",
                     "ForestModellingRLP/",
                     "ForestModellingRLP/script/",
                     "src/"
                    )
# Automatically set root direcory, folder structure and load libraries
envrmt = envimaR::createEnvi(root_folder = rootDir,
                             folders = projectDirList,
                             path_prefix = "path_",
                             libs = packagesToLoad,
                             alt_env_id = "COMPUTERNAME",
                             alt_env_value = "PCRZP",
                             alt_env_root_folder = "F:/BEN/edu")
## set raster temp path
#raster::rasterOptions(tmpdir = envrmt$path_tmp)



