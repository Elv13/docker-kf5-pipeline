# Build pipeline for KF5 based applications

This project provides multiple docker containers for each everyday tasks
related to developing a KF5 or Qt5 application:

 * Generate .deb for Debian, Kubuntu, Neon and NetRunner
 * Generate AppImage (WIP)
 * Perform Krazy2 and CppCheck checks (WIP)
 * Compile with the latest GCC + warnings
 * Compile with Clazy, clang and scan-build
 * Compile with Coverity (TM)
 * Run tests using a fake X11 server
 * Generate bootable virtual machines using the packages (WIP)
 * Keep an apt repository updated
 * Expose an apt repository over http

It generates the following artifacts:

 * .deb packages + repositories
 * Krazy2 and CppCheck logs (WIP)
 * Build logs
 * Parsed warning logs (WIP)
 * Regressed warnings logs (WIP)
 * Coverage log (WIP)

## Try it

    # Before building
    export EMAIL=foo@example.com
    export PROJECT=myproject #ex: ring-kde
    export COV_TOKEN=XXXXXX # Get from the coverity instruction page
    export VERSION=17.08
    export BRANCH=master

    # Build the containers
    docker build docker-maui-base/ -t elv13/maui-base
    # Copy the "debian" directory into $PWD/kf5-project-builder
    docker buils docker-kf5-build-env/ -t elv13/kf5-project-builder \
        --build-arg project=${PROJECT} --build-arg branch=${BRANCH}
    docker build docker-kf5-coverity -t elv13/kf5-project-coverity \
        --build-arg token=${COV_TOKEN} \
        --build-arg project=${PROJECT} --build-arg email=${EMAIL} \
        --build-arg version=${VERSION}
    docker build docker-kf5-clazy-scanbuild -t elv13/kf5-project-clazy-scanbuild
    docker build docker-kf5-dotdeb -t elv13/kf5-project-dotdeb
    docker build docker-apt-repository/ -t elv13/apt-repository
    docker build docker-apt-httpd/ -t elv13/apt-httpd

    # Run them
    docker run -it -v $PWD/debs:/public/ elv13/maui-base
    docker run -it elv13/kf5-project-clazy-scanbuild
    docker run -it elv13/kf5-project-coverity
    docker run -it -v $PWD/debs:/exportdebs/ elv13/kf5-project-dotdeb
    docker run -v $PWD/debs:/public/ elv13/apt-repository
    docker run -p80:80 -p443:443 -v $PWD/debs:/var/www/html/ elv13/apt-httpd

    # Remember to add some cron jobs to rebuild the image every weeks

## Unfinished

There is a partially working docker based vm generator. It create a netrunner
image, but its misisng the MBR and I don't want to waste anymore time doing
what oVirt has built-in.

## Note

Some things are called `kf5-project`, the next release of Docker will add a
meta base support, so it will be fixed then.
