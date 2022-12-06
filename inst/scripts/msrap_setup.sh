#!/usr/bin/env sh

# Author: Sean Maden
# 
# Sets up the MetaSRA-pipeline fork for python3. Run this after cloning from 
# GitHub:
# > git clone https://github.com/metamaden/MetaSRA-pipeline
# 
# 

# get dependencies
python2 -m pip install numpy scipy scikit-learn setuptools marisa-trie dill 
python2 -m pip install rdflib xlsxwriter pygraphviz
python2 -m pip install nltk==3.4
python2 -c "import nltk; nltk.download('punkt')"

# add pipeline dir paths to pythonpath
PYTHONPATH=/MetaSRA-pipeline/:/MetaSRA-pipeline/bktree/:/MetaSRA-pipeline/map_sra_to_ontology/

cd ./MetaSRA-pipeline/setup_map_sra_to_ontology

# clone bktree repo
sudo rm -r bktree
sudo git clone https://www.github.com/ahupp/bktree

./setup.sh # run setup, inc. ontology downloads

# test the pipeline
cd -
python2 ./MetaSRA-pipeline/run_pipeline.py --fnvread ./jsonexe --fnvwrite ./jsonexe.out
