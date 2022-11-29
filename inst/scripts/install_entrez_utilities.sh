#!/usr/bin/env sh

# Setup/install instructions from https://www.ncbi.nlm.nih.gov/books/NBK179288/
#
# 

# from a terminal window, run:
 sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"
 sh -c "$(wget -q ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh -O -)"

 # edit the env path
 # this is the prompt returned:
 # echo "export PATH=\$PATH:\$HOME/edirect" >> $HOME/.bash_profile
 # you may also answer "y" to the final command line prompt

 # after successful installation, run:
 export PATH=${PATH}:${HOME}/edirect