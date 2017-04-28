# Watch a directory for new .deb and update the repository index.
# It is a separate container from the package generator as multiple
# builder can be multiplexed on multiple cloud instance while the
# repository indexer needs only 1 instance (assuming the shared
# directory is using NFS)

FROM ubuntu:16.04
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

RUN apt update
RUN apt upgrade -y

RUN apt install -yy dpkg-dev apt-utils

WORKDIR /public

CMD while [ true ]; do \
     mkdir -p netrunner;\
     mv *.deb netrunner/;\
     dpkg-scanpackages -m netrunner /dev/null | gzip -9c > ./netrunner/Packages.gz;\
 done
