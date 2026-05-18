# pizzR

> *Copyright 2022 [piledge]. Licensed under the MIT license.*

`pizzR` is a small collection of R-Functions created by a Pizza-enthusiast. Although there is no specific topic, most of the functions have a background in forestry, raster data as well as tree species classification.

This package is a result of me constantly breaking the DRY principle by copy-and-pasting stuff from old projects into new ones and to have a centralized database to access the functions from several computing instances.

The `pizzR`-package does not solve any large problem, but it can help to save time by eliminating repetitive code and provide easy access to some more complicated interfaces of different packages.

This package is constantly being expanded and improved. Any ideas for new functions or bug reports will be appreciated.



## Installation

`pizzR` is currently only available through GitHub and can be downloaded easily using devtools:

```
# install.packages("devtools")
devtools::install_github("piledge/pizzR")
```


To avoid some errors installing devtools on Debian/Ubuntu, you may need to install some packages on the host prior to the installation:

```
sudo apt install libgdal-dev r-base-dev libudunits2-dev libcurl4-openssl-dev libssl-dev libzmq3-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev build-essential libcurl4-openssl-dev libxml2-dev libssl-dev libfontconfig1-dev libuv1-dev -y
```
