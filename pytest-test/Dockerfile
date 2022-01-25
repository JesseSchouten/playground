# Starting from base image
FROM ubuntu:latest

#Install Python & pip
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y python python3-pip python-dev && pip install --upgrade pip
RUN pip install pytest 
# Install dependencies via pip
# WORKDIR /usr/src/app