#!/bin/bash

# Load a previous session

if [ -e .setup ]; then
    source .setup
fi

# Get the environment variables

if [ "${EMAIL}" == "" ]; then
    echo 'Email (for the bots git commits):'
    read EMAIL
fi

if [ "${PROJECT}" == "" ]; then
    echo 'Project name (as found on kde.org):'
    read PROJECT
fi

if [ "${COV_TOKEN}" == "" ]; then
    echo 'Coverity token (see their upload page) OPTIONAL:'
    read COV_TOKEN
fi

if [ "${VERSION}" == "" ]; then
    echo 'Project version (for the packages):'
    read VERSION
fi

if [ "${BRANCH}" == "" ]; then
    echo 'The git branch to fetch (press enter for `master`):'
    read BRANCH
    if "${BRANCH}" == "" ]; then
        BRANCH=master
    fi
fi

echo ===========IMPORTANT===========
echo Place a valid `debian` directory in `docker-kf5-build-env/`.
echo Press return when done
echo ===========IMPORTANT===========
read

# Export the variables TODO remove
export EMAIL=${EMAIL}
export PROJECT=${PROJECT}
export COV_TOKEN=${COV_TOKEN}
export VERSION=${VERSION}
export BRANCH=${BRANCH}

# Save the answers to void asking again
echo export EMAIL=${EMAIL} > .setup
echo export PROJECT=${PROJECT} >> .setup
echo export COV_TOKEN=${COV_TOKEN} >> .setup
echo export VERSION=${VERSION} >> .setup
echo export BRANCH=${BRANCH} >> .setup

sudo docker build docker-maui-base/ -t elv13/maui-base

mkdir -p patches debs warnings

sudo docker build docker-kf5-build-env/ -t elv13/kf5-build-env \
        --build-arg project=${PROJECT} --build-arg branch=${BRANCH} \
        || exit 1
sudo docker build docker-kf5-coverity -t elv13/kf5-coverity \
        --build-arg token=${COV_TOKEN} \
        --build-arg project=${PROJECT} --build-arg email=${EMAIL} \
        --build-arg version=${VERSION} # Allowed to fail
sudo docker build docker-kf5-instrument -t elv13/kf5-instrument || exit 1
sudo docker build docker-kf5-clazy-scanbuild -t \
        elv13/kf5-clazy-scanbuild || exit 1
sudo docker build docker-kf5-clazy-fixit -t elv13/kf5-clazy-fixit \
        --build-arg email=${EMAIL} || exit 1
sudo docker build docker-kf5-dotdeb -t elv13/kf5-dotdeb || exit 1
sudo docker build docker-apt-repository/ -t elv13/apt-repository || exit 1
sudo docker build docker-apt-httpd/ -t elv13/apt-httpd || exit 1
