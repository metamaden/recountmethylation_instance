#!/usr/bin/env R

# Author: Sean Maden
# Get vectors of GSM IDs from latest data freezes. These are excluded from 
# new instances prior to running server.py, to ensure only the latest 
# available samples are included.

freeze.fname.hm450k <- "remethdb_h5se-rg_hm450k_0-0-2_1607018051"
freeze.fname.epic <- "remethdb_h5se-rg_epic_0-0-2_1589820348"
rg.hm450k <- HDF5Array::loadHDF5SummarizedExperiment(freeze.fname.hm450k)
rg.epic <- HDF5Array::loadHDF5SummarizedExperiment(freeze.fname.epic)

gsmv <- c(gsub("\\..*", "", colnames(rg.hm450k)), gsub("\\..*", "", colnames(rg.epic)))
write(paste(gsmv, collapse = " "), file = "gsmv.txt")