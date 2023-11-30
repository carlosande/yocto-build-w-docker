# Copyright 2023

# https://docs.docker.com/engine/reference/builder/
# https://witekio.com/blog/5-steps-to-compile-yocto-using-docker-containers/


# In any directory on the docker host, perform the following actions:
#   * Copy this Dockerfile in the directory.
#   * Create input and output directories: mkdir -p yocto/output yocto/input
#   * Build the Docker image with the following command:
#     docker buildx build --no-cache -f Dockerfile --build-arg "host_uid=$(id -u)" --build-arg "host_gid=$(id -g)" --tag "rpi4linux-image:latest" .
#   * Run the Docker image, which in turn runs the Yocto and which produces the Linux rootfs,
#     with the following command:
#     docker run -it --rm rpi4linux-image:latest
#     docker run -it rpi4linux-image:latest
#     docker run -it rpi4linux-image:latest /bin/bash
#	  Expose output dir to host OS
#     docker run -it --rm -v $PWD/yocto/output:/home/devel/yocto/output rpi4linux-image:latest
#     docker run -it --rm -v $PWD/yocto/output:/home/devel/yocto/output rpi4linux-image:latest /bin/bash

# Use Ubuntu 22.04 LTS as the basis for the Docker image.
FROM ubuntu:22.04

# To skip interaction with user when running apt-get, specially timezone setup
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y upgrade
	
# Install all the Linux packages required for Yocto builds. 
RUN apt-get install -yq gawk wget git-core diffstat unzip curl file \
            texinfo gcc-multilib build-essential chrpath socat cpio xz-utils \
            python3 python3-pip python3-pexpect python3-git python3-jinja2 python3-distutils \
            libegl1-mesa libsdl1.2-dev xterm locales debianutils iputils-ping \
            vim nano bash-completion screen sysstat cpio tmux sudo iputils-ping iproute2 \
			fluxbox tightvncserver liblz4-tool zstd parted tzdata

# Fix timezone issue
ENV TZ="America/Sao_Paulo"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#### https://github.com/blackducksoftware/docker-scanning-pattern/blob/master/ubuntu-1804-with-python38.dockerfile			
#
# Python3.8 install for Ubuntu
#
# ref: https://linuxize.com/post/how-to-install-python-3-8-on-ubuntu-18-04/
#RUN apt-get update
#RUN apt-get install -y software-properties-common
#RUN add-apt-repository ppa:deadsnakes/ppa
#RUN apt-get install -y python3.8 python3-pip
# Update symlink to point to latest
#RUN rm /usr/bin/python3 && ln -s /usr/bin/python3.8 /usr/bin/python3 && ln -s /usr/bin/python3.8 /usr/bin/python

# By default, Ubuntu uses dash as an alias for sh. Dash does not support the source command
# needed for setting up the build environment in CMD. Use bash as an alias for sh.
RUN rm /bin/sh && ln -s bash /bin/sh

# Set the locale to en_US.UTF-8, because the Yocto build fails without any locale set.
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV USER_NAME devel
ENV PROJECT rpi4-64

# The running container writes all the build artefacts to a host directory (outside the container).
# The container can only write files to host directories, if it uses the same user ID and
# group ID owning the host directories. The host_uid and group_uid are passed to the docker build
# command with the --build-arg option. By default, they are both 1001. The docker image creates
# a group with host_gid and a user with host_uid and adds the user to the group. The symbolic
# name of the group and user is devel.
ARG host_uid=1000
ARG host_gid=1000
RUN groupadd -g $host_gid $USER_NAME && useradd -g $host_gid -m -s /bin/bash -u $host_uid $USER_NAME

# Perform the Yocto build as user devel (not as root).
# NOTE: The USER command does not set the environment variable HOME.

# By default, docker runs as root. However, Yocto builds should not be run as root, but as a 
# normal user. Hence, we switch to the newly created user devel.
USER $USER_NAME

# Create the directory structure for the Yocto build in the container. The lowest two directory
# levels must be the same as on the host.
ENV BUILD_INPUT_DIR /home/$USER_NAME/yocto/sources
ENV BUILD_OUTPUT_DIR /home/$USER_NAME/yocto/output

RUN mkdir -p $BUILD_INPUT_DIR $BUILD_OUTPUT_DIR/$PROJECT

WORKDIR $BUILD_INPUT_DIR

RUN git clone https://git.yoctoproject.org/poky.git 
WORKDIR $BUILD_INPUT_DIR/poky 
RUN git clone https://git.yoctoproject.org/meta-raspberrypi.git
RUN git clone https://github.com/openembedded/meta-openembedded.git
RUN git checkout -b nanbield origin/nanbield
WORKDIR $BUILD_INPUT_DIR/poky/scripts
#RUN ["/bin/bash", "./install-buildtools"] #### this does not work ###
WORKDIR $BUILD_INPUT_DIR
RUN mkdir -p $BUILD_INPUT_DIR/meta-rpilinux
COPY --chown=$USER_NAME:$USER_NAME --chmod=777 ./meta-rpilinux  $BUILD_INPUT_DIR/meta-rpilinux 

WORKDIR $BUILD_OUTPUT_DIR

# Clone the repositories of the custom meta layers into the directory $BUILD_OUTPUT_DIR/$PROJECT.
# RUN git clone --recurse-submodules https://github.com/carlosande/$PROJECT.git
COPY --chown=$USER_NAME:$USER_NAME --chmod=777 ./$PROJECT $BUILD_OUTPUT_DIR/$PROJECT

# Prepare Yocto's build environment. If TEMPLATECONF is set, the script oe-init-build-env will
# install the customised files bblayers.conf and local.conf. This script initialises the Yocto
# build environment. The bitbake command builds the rootfs for our embedded device.
# ENV TEMPLATECONF=$BUILD_INPUT_DIR/meta-rpilinux

CMD source $BUILD_INPUT_DIR/poky/oe-init-build-env $BUILD_OUTPUT_DIR/$PROJECT \
    && bitbake -k -v rpilinux-image



