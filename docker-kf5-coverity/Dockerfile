# Upload results to Coverity (tm) for static analysis

FROM elv13/kf5-build-env
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

ARG token
ARG project
ARG email
ARG version

# Check the required args
RUN bash -c "if [ \"${token}\" == '' ]; then exit 1; fi"
RUN bash -c "if [ \"${project}\" == '' ]; then exit 1; fi"
RUN bash -c "if [ \"${email}\" == '' ]; then exit 1; fi"
RUN bash -c "if [ \"${version}\" == '' ]; then exit 1; fi"

RUN apt install curl wget -y

RUN wget https://scan.coverity.com/download/linux64 \
 --post-data "token=${token}&project=${project}" -O coverity.tgz

RUN mkdir /opt/coverity;  tar -xpvf coverity.tgz -C /opt/coverity ;\
 rm coverity.tgz

# Create an upload script
RUN echo curl \
 --form token=${token} \
 --form email=${email} \
 --form file=@${project}.xz \
 --form version="${version}" \
 --form description="Description" \
 https://scan.coverity.com/builds?project=${project} \
 > /usr/bin/cov-upload.sh

RUN chmod +x /usr/bin/cov-upload.sh

RUN echo ${project} > /projectname.txt

CMD git pull --rebase && \
 mkdir build; cd build; \
 cmake ..&&\
 /opt/coverity/cov*/bin/cov-build --dir cov-int  make -j8 &&\
 echo Compressing results &&\
 tar caf $(cat /projectname.txt).xz cov-int &&\
 echo Uploading &&\
 cov-upload.sh
