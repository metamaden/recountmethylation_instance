#!/usr/bin/env R

# Author: Sean Maden
#
# Install R dependencies.
#
install_dependencies <- function(){
    message("Beginning to install R dependencies...")
    message("Installing CRAN dependencies...")
    install.packages("data.table", repos='http://cran.us.r-project.org')
    message("Installing Bioconductor dependencies...")
    if (!requireNamespace("BiocManager", quietly = TRUE)){
      install.packages("BiocManager", repos='http://cran.us.r-project.org')}
    BiocManager::install("minfi", "DelayedArray", "HDF5Array", "recountmethylation")
    message("Installing GitHub dependencies...")
    devtools::install_github("hhhh5/ewastools")
    devtools::install_github("metamaden/recountmethylation.pipeline")
    devtools::install_github("metamaden/recount.synth")
    return(NULL)
}

install_dependencies()