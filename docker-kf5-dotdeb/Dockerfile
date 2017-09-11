# Generate some .deb of the latest commit for maui
# Getting them for other Debian based variants also works
# as long as both the builder image and this are rebuilt
# using another `FROM`

FROM elv13/kf5-build-env
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

CMD git pull --rebase && \
 VERSION=$(dpkg-parsechangelog --show-field Version | cut -d: -f2);\
 VERSION=$(echo $VERSION | cut -f1 -d\-);\
 PROJECT=$(dpkg-parsechangelog --show-field Source);\
 tar -cj . -f ../../../${PROJECT}_${VERSION}.orig.tar.bz2 && \
 dpkg-buildpackage -j9 && \
 chmod 755 /*.deb && \
 cp /*.deb /exportdebs/
