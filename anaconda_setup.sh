#!/usr/bin/env bash

# Author: Sean Maden
# 
# Install and manage Anaconda environments for recountmethylation_instance
# This script should be runnable on Mac, Linux, or within Ubuntu for Windows, 
# with conda already installed. It creates 2 virtual environments, `py3`, 
# which is the main environment to manage an instance and synchronize data, 
# and `py2`, which is a secondary environment to run the MetaSRA-pipeline.

#----------------------------------------
# install python distros for environments
#----------------------------------------
conda update conda
conda install python=3.7.0
conda install python=2.7.18

conda install -c bioconda bioconductor-biocinstaller

#-----------------------
# clone dependency repos
#-----------------------
git clone https://github.com/metamaden/recountmethylation_instance
cd recountmethylation_instance
git clone https://github.com/metamaden/recountmethylation_server
git clone https://github.com/metamaden/recountmethylation.pipeline
git clone https://github.com/metamaden/MetaSRA-pipeline
#conda git clone https://github.com/metamaden/recount.synth

#----------------------
# main environment, py3
#----------------------
# set up environment with python3, R, other dependencies
conda create -n py3 python=3.7.0; conda activate py3

# additional dependencies
conda install -c anaconda mongodb
conda install -c anaconda sqlite3
conda install r=3.6.0

# install entrez direct utilities

# required python3 libs
conda install pandas=0.25.1
conda install pymongo=3.7.2 
conda install celery
conda install snakemake

# optional python3 libs
conda install plotly=4.14.3
conda install dash

# r lib manual dependency installs
conda install boost=1.73.0 # RSQLite dependency
conda install openblas #  preprocesscore dependency

# use bioconda to bypass permissions issues
conda install -c bioconda r-xml2 
conda install -c bioconda r-rlang
conda install -c bioconda r-nlme
conda install -c bioconda r-cluster
conda install -c bioconda dplyr
conda install -c bioconda bioconductor-biobase
conda install -c bioconda bioconductor-geoquery
conda install -c bioconda bioconductor-bumphunter
conda install -c bioconda bioconductor-genefilter
conda install -c bioconda bioconductor-rhdf5
conda install -c bioconda bioconductor-preprocesscore
# conda update curl
R
install.packages("dplyr")
install.packages("BiocManager")
install.packages("data.table")
BiocManager::install("RSQLite")
BiocManager::install("S4Vectors")
BiocManager::install("SummarizedExperiment")
BiocManager::install("GenomicFeatures")
BiocManager::install("AnnotationDbi")
BiocManager::install("minfi")
BiocManager::install("minfiData")
BiocManager::install("minfiDataEPIC")
BiocManager::install("HDF5Array")
quit()

# install pipeline lib
R CMD INSTALL recountmethylation.pipeline

# get the environment.yml file
conda env export > environment_rmi_py3.yml

conda deactivate py3

#--------------------------------------
# environment for MetaSRA-pipeline, py2
#--------------------------------------
# optional, run if metadata mapping with the pipeline is desired
conda create -n py2 python=2.7; conda activate py2

# install python2 libs
conda install numpy 
conda install scipy
conda install scikit-learn
conda install setuptools
conda install marisa-trie
conda install dill
conda install nltk
conda install snakemake

# further steps to set up the pipeline
python2 $setupscriptspath"punkt_setup.py"
python2 $setupscriptspath"punkt_setup.py" # get punkt for nltk
sh $setupscriptspath"msrap_setup.sh" # run pipeline setup script

# get the environment.yml file
conda env export > environment_rmi_py2.yml

conda deactivate py2
