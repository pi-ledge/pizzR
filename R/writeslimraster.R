writeslimRaster <- function(rasterobject, filename, compression=T, overwrite=T, BIGTIFF="YES", filetype="GTiff", datatype="ESTIMATE", ...){

  pizzR::package.install(c("raster", "terra"), verbose = 1)

  rsttype <- class(rasterobject)[1]
  if (rsttype != "SpatRaster" && rsttype != "RasterLayer" && rsttype != "RasterBrick" && rsttype != "RasterStack") return(warning("Not a suitable rasterfile!\n"))
  if (!is.logical(compression)) return(warning("'compression' needs to be boolean!\n"))
  if (!is.logical(overwrite)) return(warning("'overwrite' needs to be boolean!\n"))
  if (BIGTIFF != "YES" && BIGTIFF != "NO" && BIGTIFF != "IF_SAFER" && BIGTIFF != "IF_NEEDED") return(warning("'BIGTIFF' should be one of the following options: YES/NO/IF_SAFER/IF_NEEDED!\n"))
  if (datatype != "LOG1S" && datatype != "INT1S" && datatype != "INT1U" && datatype != "INT2S" && datatype != "INT2U" && datatype != "INT4S" && datatype != "INT4U" && datatype != "FLT4S" && datatype != "FLT8S" && datatype != "ESTIMATE") return(warning("'datatype' should be either ESTIMATE or one of the following options: LOG1S/INT1S/INT1U/INT2S/INT2U/INT4S/INT4U/FLT4S/FLT8S!\n"))

  fparameters             <- list(...)
  fparameters$filename    <- filename
  fparameters$overwrite   <- overwrite
  fparameters$datatype    <- datatype
  fparameters$filetype    <- filetype

  if (rsttype == "SpatRaster"){

    if (compression == TRUE && datatype == "ESTIMATE"){
      cat(paste0("\n", pizzR::Systime(), ": Estimate datatype ..."))
      fparameters$datatype                                                      <- pizzR::opt.datatype(rasterobject)
    }
    if (compression == TRUE)  fparameters$gdal                                  <- c(paste0("BIGTIFF = ", BIGTIFF), "COMPRESS = DEFLATE", "ZLEVEL = 9", "PREDICTOR = 2")
    if (compression == FALSE) fparameters$gdal                                  <- c(paste0("BIGTIFF = ", BIGTIFF))

    if (compression == TRUE)  cat(paste0("\n", pizzR::Systime(), ": Write slim rasterfile as '", fparameters$datatype,"' ...\n"))
    if (compression == FALSE) cat(paste0("\n", pizzR::Systime(), ": Write rasterfile ...\n"))
    terra::setMinMax(rasterobject, force = T)
    fparameters$x                                                               <- rasterobject
    do.call(terra::writeRaster, fparameters)
  }

  if (rsttype == "RasterLayer" || rsttype == "RasterBrick" || rsttype == "RasterStack"){

    if (compression == TRUE && datatype == "ESTIMATE"){
      cat(paste0("\n", pizzR::Systime(), ": Estimate datatype ..."))
      fparameters$datatype                                                      <- pizzR::opt.datatype(x, samplesize)
    }
    if (compression == TRUE && datatype != "ESTIMATE") fparameters$datatype     <- datatype
    if (compression == TRUE) fparameters$options                                <- c("COMPRESS=DEFLATE", "PREDICTOR=2", "ZLEVEL=9")

    if (compression == TRUE)  cat(paste0("\n", pizzR::Systime(), ": Write slim rasterfile as '", fparameters$datatype,"' ...\n"))
    if (compression == FALSE) cat(paste0("\n", pizzR::Systime(), ": Write rasterfile ...\n"))
    fparameters$x                                                               <- rasterobject
    do.call(raster::writeRaster, fparameters)
  }
  cat(paste0(pizzR::Systime(), ": Done ...\n"))
}
