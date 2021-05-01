#!/usr/bin/env sh

# Author: Sean Maden
# This script provides a complete setup for a new instance of 
# recountmethylation. Setup is started by building the Docker image, and 
# completed by setup.sh in the newly started container.

#-------------------
# run docker compose
#-------------------
# Docker compose .yml file allows us to run and manage services in addition to 
# the main image defined by the Dockerfile. In our case, we use the compose file
# to install and manage the MongoDB dependencies.
docker-compose up -d

# now log into the running container
docker container ls
# docker exec -it <container_name> bash
docker exec -it mongodb bash

#-----------------------------------
# Use image to start a new container
#-----------------------------------
# pull latest image from docker hub
docker pull metamaden/recountmethylation_docker
# build image
docker build -t metamaden/recountmethylation_docker .
# run an interactive container
docker run -it metamaden/recountmethylation_docker /bin/bash



#----------------------
# check your os version
#----------------------
cat /etc/os-release
# NAME="Ubuntu"
# VERSION="16.04.6 LTS (Xenial Xerus)"
# ID=ubuntu
# ID_LIKE=debian
# PRETTY_NAME="Ubuntu 16.04.6 LTS"
# VERSION_ID="16.04"
# HOME_URL="http://www.ubuntu.com/"
# SUPPORT_URL="http://help.ubuntu.com/"
# BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
# VERSION_CODENAME=xenial
# UBUNTU_CODENAME=xenial

#------------------------
# entrez direct utilities
#------------------------
# get the install script
curl https://www.ncbi.nlm.nih.gov/books/NBK179288/bin/install-edirect.sh \
--output install-edirect.sh
source ./install-edirect.sh
echo "export PATH=\$PATH:\$HOME/root/edirect" >> $HOME/.bash_profile

#---------------------------------
# use homebrew for large utilities
#---------------------------------
# get latest taps
brew update
brew tap brewsci/bio
# install utilities
brew install r
brew install python
brew install unzip
brew install rabbitmq
brew cleanup 

#--------
# mongodb
#--------
sudo apt-get update
sudo apt-get install wget

# approach: use tar -- DOESN'T WORK
# sudo apt-get install libcurl3 openssl liblzma5
# wget https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-4.4.3.tgz
# tar -zxvf mongodb-macos-x86_64-4.4.3.tgz
# sudo cp /root/mongodb-macos-x86_64-4.4.3/bin/* /usr/local/bin/
# sudo mkdir -p /var/lib/mongo
# sudo mkdir -p /var/log/mongodb
# sudo chown `whoami` /var/lib/mongo
# sudo chown `whoami` /var/log/mongodb
# mongod --dbpath /var/lib/mongo --logpath /var/log/mongodb/mongod.log --fork
# head /var/log/mongodb/mongod.log
# mongo

# mongodb
brew tap mongodb/brew
brew install mongodb-community@4.4


sudo apt-get install -y mongodb 
# limit temp data

#-----------------
# python3 packages
#-----------------
pip3 install celery==5.0.5 \
    numpy==1.20.1 \
    scipy==1.6.0 \
    pymongo==3.11.3

# install server as python package
pip3 install recountmethylation_server

#---------------
# r 4## packages
#---------------
# from command line
Rscript -e `install.packages("BiocManager", \
    "data.table"\
    "knitr"\
    "ggplot2"\
    "gridExtra");\
    BiocManager::install("minfi", \
        "HDF5Array", \
        "rhdf5", \
        "DelayedArray", \
        "recountmethylation")`


RUN Rscript -e 'install.packages(repos = c(CRAN = "https://cran.rstudio.com"), c( \
"devtools", \
"ggplot2", \
"knitr", \
"rmarkdown", \
"tidyverse", \
"BiocManager")); BiocManager::install()'

# install python2 and pip2 for ubuntu
# apt install python-minimal
# apt install python-pip

# pip2/python2
# pip2 install dill
# pip2 install pygraphviz
# pip2 install config
# pip2 install nltk
# pip2 install bktree
# pip2 install marisa_trie

# share container folders on container start (windows)
# > docker create -t -i -v <host_path>:<container_path> <image> <command>





