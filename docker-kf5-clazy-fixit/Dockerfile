# Run the KDE Clazy static analysis tool and CLANG scan-build on
# the package. This generate an useful build-log with all warnings.

FROM elv13/kf5-instrument
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

ARG email

RUN mkdir /patches

RUN git config --global user.email ${email}
RUN git config --global user.name "KF5 linting bot"


ADD scripts/fixall.sh /usr/bin/

CMD fixall.sh
