#!/usr/bin/env sh 

# Author: Sean Maden
#
# Set up a recountmethylation instance. Gets dependencies and installations for
# the instance.
#

setupscriptspath=./inst/setup/

git clone https://github.com/metamaden/recountmethylation_server
git clone https://github.com/metamaden/recountmethylation.pipeline
git clone https://github.com/metamaden/recount.synth
git clone https://github.com/metamaden/MetaSRA-pipeline

# install python3 dependencies
python3 -m pip install pymongo
python3 -m pip install celery
python3 -m pip install plotly
python3 -m pip install pandas
python3 -m pip install dash
python3 -m pip install snakemake

# install python2 dependencies
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

# test installations
# python3 ./recountmethylation_server/src/start_server.py