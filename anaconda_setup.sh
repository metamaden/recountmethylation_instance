#!/usr/bin/env bash

# Author: Sean Maden
# Install and manage anaconda environments for recountmethylation_instance
# This script should be runnable on Mac, Linux, or within Ubuntu for Windows.

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
git clone https://github.com/metamaden/recountmethylation_server
git clone https://github.com/metamaden/recountmethylation.pipeline
git clone https://github.com/metamaden/MetaSRA-pipeline
#conda git clone https://github.com/metamaden/recount.synth

#----------------------
# main environment, py3
#----------------------
# set up environment with python3, R, other dependencies
conda create -n py3 python=3.7.0
conda activate py3

# additional dependencies
conda install -c anaconda mongodb
conda install -c anaconda sqlite3
conda install r=3.6.0

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
conda install openblas==0.3.7 #  preprocesscore dependency

# use bioconda to bypass permissions issues
conda install -c bioconda r-xml2 
conda install -c bioconda r-rlang
conda install -c bioconda r-nlme
conda install -c bioconda r-cluster
conda install -c bioconda bioconductor-biobase
conda install -c bioconda bioconductor-geoquery
conda install -c bioconda bioconductor-bumphunter
conda install -c bioconda bioconductor-genefilter

# BiocManager::install("preprocessCore")
# BiocManager::install("preprocessCore", configure.args="--disable-threading")
conda install -c bioconda bioconductor-preprocesscore
# conda install -c bioconda/label/gcc7 bioconductor-preprocesscore
conda update curl
R
install.packages("BiocManager")
BiocManager::install("RSQLite")
BiocManager::install("SummarizedExperiment")
BiocManager::install("GenomicFeatures")
BiocManager::install("AnnotationDbi")
BiocManager::install("bumphunter")
BiocManager::install("minfi")
BiocManager::install("minfiData") 
BiocManager::install("minfiDataEPIC")
BiocManager::install("rhdf5")
BiocManager::install("HDF5Array")
BiocManager::install("data.table")

# get the environment.yml file
conda env export > environment_py3.yml

conda deactivate py3

#---------------------------------
# environment for MetaSRA-pipeline
#---------------------------------
# optional, run if metadata mapping with the pipeline is desired
conda create -n py2 python=2.7
conda activate py2
conda install numpy scipy scikit-learn setuptools marisa-trie dill nltk
pip install snakemake

# further steps to set up the pipeline
python2 $setupscriptspath"punkt_setup.py"
python2 $setupscriptspath"punkt_setup.py" # get punkt for nltk
sh $setupscriptspath"msrap_setup.sh" # run pipeline setup script






conda git clone https://github.com/metamaden/recountmethylation_instance
conda git clone https://github.com/metamaden/recountmethylation_server
conda git clone https://github.com/metamaden/recountmethylation.pipeline
conda git clone https://github.com/metamaden/recount.synth
conda git clone https://github.com/metamaden/MetaSRA-pipeline

conda listenv

# install python3 dependencies
conda switch # switch to python3 env
conda install pymongo celery plotly pandas dash snakemake
conda install -c anaconda mongodb

python3 -m pip install pymongo
python3 -m pip install celery
python3 -m pip install plotly
python3 -m pip install pandas
python3 -m pip install dash
python3 -m pip install snakemake
conda install -c anaconda mongodb

# install python2 dependencies
conda switch # switch to python3 env
conda install numpy scipy scikit-learn setuptools marisa-trie dill nltk

python2 -m pip install numpy 
python2 -m pip install scipy 
python2 -m pip install scikit-learn
python2 -m pip install setuptools
python2 -m pip install marisa-trie
python2 -m pip install dill
python2 -m pip install nltk

# get punkt for nltk
python2 $setupscriptspath"punkt_setup.py"

# setup up MetaSRA-pipeline
sh $setupscriptspath"msrap_setup.sh"

# run R setup
Rscript $setupscriptspath"r_setup.R"
