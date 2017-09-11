# Install the KDE Clazy static analysis tool, CLANG scan-build and
# other LLVM based static tooling.
# the package. This generate an useful build-log with all warnings.

FROM elv13/kf5-build-env
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

RUN apt remove gcc g++ -y
RUN apt install clang libclang-dev clang-tidy -y

RUN cd /; git clone https://anongit.kde.org/clazy
RUN cd /clazy && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=/usr &&\
 make -j8 && make install

ENV CC=clang
ENV CXX=clazy
ENV CLAZY_CHECKS="level2"
