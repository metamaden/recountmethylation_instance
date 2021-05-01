# get base image
FROM linuxbrew/brew:2.1.10

# environment variables
LABEL maintainer="maden.sean@gmail.com" \
name="metamaden/recountmethylation_docker"
ENV HOMEBREW_NO_AUTO_UPDATE=1

# update utils
# RUN brew update
RUN apt update && \
	yes | apt install python-minimal && \
	yes | apt install python-pip && \
	apt purge -y
RUN apt-get update && \
	apt-get -y --no-install-recommends install \
	git \
	zip && \
	# apt-get purge -y git && \
	apt-get autoremove -y && \
	apt-get clean

# python2 libraries
RUN pip2 install \
	numpy==1.15.0 \
	scipy==0.16 \
	dill==0.3.3 \
	config==0.5.0 \
	nltk==3.4 \
	bktree==0.1 \
	marisa_trie==0.7.5

# clone repos to working dir
RUN mkdir /home/recountmethylation
WORKDIR /home/recountmethylation
RUN cd /home/recountmethylation
RUN git clone https://github.com/metamaden/recountmethylation_server && \
	git clone https://github.com/metamaden/rmpipeline && \
	git clone https://github.com/metamaden/MetaSRA-pipeline

# homebrew
#RUN brew update && \
#	brew tap brewsci/bio
# install libs and utilities
#RUN brew install \
#	r \
#	python \
#	unzip && \
#	brew cleanup

# install python3 libraries
# RUN pip3 install \
#	numpy \
#	scipy \
#	celery \
#	pymongo

# omitted due to large layer size
# RUN brew install rabbitmq
# RUN brew tap mongodb/brew && \
# 	brew install \
# 	mongodb-community@4.0 \
# 	rabbitmq \
#	sqlite