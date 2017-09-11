#!/bin/bash

#sudo docker run -it -v $PWD/debs:/public/ elv13/maui-base
sudo docker run -t -v $PWD/warnings:/warnings elv13/kf5-clazy-scanbuild
sudo docker run -t -v $PWD/patches:/patches elv13/kf5-clazy-fixit
sudo docker run -t elv13/kf5-coverity
sudo docker run -t -v $PWD/debs:/exportdebs/ elv13/kf5-dotdeb
sudo docker run -v $PWD/debs:/public/ elv13/apt-repository
#sudo docker run -p80:80 -p443:443 -v $PWD/debs:/var/www/html/ elv13/apt-httpd
sudo docker run -v $PWD/warnings/:/warnings/ -ti elv13/kf5-krazy

