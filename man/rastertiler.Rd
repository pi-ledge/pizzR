\name{rastertiler}
\alias{rastertiler}
\title{Split extent of a SpatialRaster in n tiles.}
\usage{
rastertiler()
}
\arguments{
\item{x}{SpatialRaster.}
\item{nslices_h}{integer. Horizontal number of slices.}
\item{nslices_v}{integer. Vertical number of slices.}
\item{overlap_h}{integer. Number of overlapping pixels in horizontal direction.}
\item{overlap_v}{integer. Number of overlapping pixels in vertical direction.}
\item{verbose}{logical. Plot additional output.}
}
\description{
Returns a list including the extent of the input raster, split in a number of subsets. If required, an overlapping area for the tiles can be specified.
If \code{is.integer(nrow / nslices_x) == F} or \code{is.integer(ncol / nslices_y == F}, the remaining pixels will be added to the right and bottom tiles.
}
\examples{
library(terra)
library(pizzR)

# define a SpatialRaster
size <- 100
r <- rast(nrows=size, ncols=size, ext=ext(c(0,size,0,size)), vals=sample(size, size^2, replace = T))


# slice the SpatialRaster tiles
tiles <- rastertiler(r, nslices_h = 2, nslices_v = 3, verbose=T)
tiles

# slice the SpatialRaster tiles with 3 pixels larger in size
tiles <- rastertiler(r, nslices_h = 2, nslices_v = 3, overlap_h = 9, overlap_v = 9, verbose=T)
tiles
}
