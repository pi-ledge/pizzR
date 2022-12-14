\name{setcreate.wd}
\alias{setcreate.wd}
\title{A useful combination of setwd() and dir.create()}
\usage{
setcreate.wd(x)
}
\arguments{
\item{x}{path}
}
\description{
Can be used instead of setwd(). Creates recursive path prior to change of working directory.
}
\examples{
library(pizzR)

currend.wd <- tempdir()

# create new folder if not exist and change working directory
setcreate.wd(paste0(currend.wd,"/samplefolder"))

# change working directory if exist
setcreate.wd(currend.wd)
}
