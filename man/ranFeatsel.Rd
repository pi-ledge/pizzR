\name{rfFeatsel}
\alias{rfFeatsel}
\title{Random-Forest Models with Feature Selection.}
\usage{
rfFeatsel(x, y, ...)
}
\arguments{
\item{x}{dataframe including features.}
\item{y}{dataframe or vector including sample-denominations.}
\item{featsel}{logical. If \code{TRUE}, a recursive feature selection will be performed.}
\item{keepmodels}{logical. If \code{TRUE}, all models created during feature selection will be kept.}
\item{seed}{integer. Specify static seed. If \code{NULL}, random seed will be used. Overrides external usage of \code{set.seed()}-Function}
\item{...}{additional arguments for randomForest/ranger. See specific packages for help.}
}
\description{
...
}
\examples{
library(pizzR)

...
}
