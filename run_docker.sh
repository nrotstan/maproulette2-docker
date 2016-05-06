#!/bin/bash
DOCKER_VERSION=1.0.0
#This line gets the latest commit hash to use as the cachebust, when it changes the 
#it will break the cache on the line just before we pull the code. So that it won't use
#the cache and instead will pull the latest and repackage
export CACHEBUST=`git ls-remote https://github.com/maproulette/maproulette2.git | grep HEAD | cut -f 1`
docker build -t $DOCKER_USER/maproulette2:$DOCKER_VERSION --build-arg CACHEBUST=$CACHEBUST .

# Run it locally. Optional
if [ "$1" == "true" ]; then
	docker rm -f `docker ps --no-trunc -aq`
fi

docker stop mr2-postgis
docker rm mr2-postgis
docker run --name mr2-postgis \
	-e POSTGRES_DB=mr2_prod \
	-e POSTGRES_USER=mr2dbuser \
	-e POSTGRES_PASSWORD=mr2dbpassword \
	-d mdillon/postgis

sleep 10

docker stop maproulette2
docker rm maproulette2
docker run -t --privileged -d -p 8080:8080 \
	--name maproulette2 \
	--link mr2-postgis:db \
	$DOCKER_USER/maproulette2:$DOCKER_VERSION

docker ps