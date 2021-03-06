# Ubuntu LTS 14.04 + Apache2 + module + my app
#
# Base from ultimate-seed Dockerfile
# https://github.com/pilwon/ultimate-seed
#
# Mainly to run yapdnsui
# https://github.com/xbgmsharp/ipxe-buildweb
#
# DOCKER-VERSIO 1.0.0
# VERSION 0.0.1

# Pull base image.
FROM ubuntu:14.04
MAINTAINER Francois Lacroix <xbgmsharp@gmail.com>

# Setup system and install tools
RUN echo "initscripts hold" | dpkg --set-selections
RUN echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc

# Set locale
RUN apt-get -qqy install locales
RUN locale-gen --purge en_US en_US.UTF-8
RUN dpkg-reconfigure locales
ENV LC_ALL en_US.UTF-8

# Set ENV
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Make sure the package repository is up to date
RUN apt-get update && apt-get -y upgrade

# Install SSH
RUN apt-get install -y openssh-server
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed 's/#PermitRootLogin yes/PermitRootLogin yes/' -i /etc/ssh/sshd_config
RUN sed 's/PermitRootLogin without-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN echo 'root:admin' | chpasswd

# Add the install script in the directory.
ADD install.sh /tmp/installsh
#ADD . /app

# Install it all
RUN \
  bash /tmp/install.sh

# Define environment variables
ENV PORT 80

# Define working directory.
WORKDIR /var/www/ipxe-buildweb

# Define default command.
# Start ssh and other services.
CMD ["/bin/bash", "/tmp/install.sh"]

# Expose ports.
EXPOSE 22 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Make sure the package repository is up to date
ONBUILD apt-get update && apt-get -y upgrade
ONBUILD apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
