# This create a base image with all the build dependencies. Note that
# you have to provide a `debian` directory. It can be downloaded from
# the Debian (or Kubuntu or Neon or write your own)
# (ex: https://packages.debian.org/)
#
# The ${project} variable is also required. The ${branch} variable
# is also honored (it defauls to `master`)

FROM elv13/maui-base
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

ARG project
ARG branch=master

RUN apt-get update
RUN apt upgrade -y

RUN apt install -yy build-essential cmake git dpkg-dev devscripts equivs

RUN git clone http://anongit.kde.org/${project}

WORKDIR ${project}

RUN git checkout ${branch}

RUN echo ${project} > /projectname.txt

ADD debian /${project}/debian

# Install all dependencies
RUN mk-build-deps \
    -t 'apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -qqy' \
    -i -r debian/control
