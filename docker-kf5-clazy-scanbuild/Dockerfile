# Run the KDE Clazy static analysis tool and CLANG scan-build on
# the package. This generate an useful build-log with all warnings.

FROM elv13/kf5-instrument
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

RUN mkdir /warnings

CMD git pull --rebase && \
 mkdir build; cd build; \
 cmake ..&&\
 scan-build warningdb /warnings/clazy.json
