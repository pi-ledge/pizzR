rasterdiversity <- function(x, index='shannon', window=3, ...){

  index <- tolower(index)
  if (index != 'eveness' && index != 'raosq' && index != 'richness' && index != 'shannon' && index != 'simpson') return(warning("Index can either be 'eveness', 'raosq', 'richness', 'shannon' or 'simpson'\n"))
  if (!is.numeric(window))                                                                                       return(warning("'window' has to be of type integer\n"))
  window.divided <- window / 2
  if (window.divided - floor(window.divided) != 0.5)                                                             return(warning("'window' has to be a odd integer\n"))
  if (window > terra::nrow(x) && window > terra::ncol(x))                                                        return(warning("Focal window bigger than raster!\n"))

  pizzR::package.install(c("raster", "terra"), verbose = 1)

  library(terra)

  if (index == 'eveness'){
    fun <- function(x) {
      cnts <- table(x)
      s <- length(na.omit(cnts))
      cnts <- cnts / sum(cnts)
      shan <- -sum(cnts * log(cnts))
      shan / log(s)
    }
  }

  if (index == 'raosq'){
    div <- window^4
    method <- "euclidean"
    fun <- function(x) sum(as.matrix(dist(na.omit(x)))/div)
  }

  if (index == 'richness'){
    fun <- function(x) length(unique(na.omit(x)))
  }

  if (index == 'shannon'){
    fun <- function(x) {
      cnts <- table(x)
      cnts <- cnts / sum(cnts)
      -sum(cnts * log(cnts))
    }
  }

  if (index == 'simpson'){
    fun <- function(x) {
      p <- table(x)/length(x)
      1 / sum(p^2)
    }
  }

  fparameters             <- list(...)
  fparameters$x           <- x
  fparameters$w           <- window
  fparameters$fun         <- fun

  return(do.call(terra::focal, fparameters))
}
