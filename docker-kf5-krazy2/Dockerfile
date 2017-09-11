# Run the KDE Clazy static analysis tool and CLANG scan-build on
# the package. This generate an useful build-log with all warnings.

FROM elv13/kf5-instrument
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

RUN apt install -y libhtml-parser-perl libfile-find-object-perl \
    libtie-ixhash-perl libxml-dom-xpath-perl libyaml-perl \
    libxml-libxml-perl

RUN cd /; git clone https://github.com/Krazy-collection/krazy.git
RUN cd /krazy && ./install.sh /usr

RUN mkdir /warnings/

CMD krazy2all --export xml > /warnings/krazy2.xml
