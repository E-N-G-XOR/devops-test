#!/bin/bash

usage() { echo "Usage: $0 [-n <string>] [-u <string>] [-v <string>]" 1>&2; exit 1; }

while getopts ":n:u:v:" o; do
    case "${o}" in
        n)
            name=${OPTARG}
            ((s == 45 || s == 90)) || usage
            ;;
        u)
            uri=${OPTARG}
            ;;
        v)
            verion=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${n}" ] || [ -z "${u}" ]; then
    usage
fi

echo "s = ${s}"
echo "p = ${p}"

if [ ! -z "${name}" ]
then
  echo ""
  echo "Hey, name value was not set."
  echo ""
  exit
fi
if [ ! -z "${uri}" ]
then
  echo ""
  echo "Hey, we need the url to push to!"
  echo ""
  exit
fi
if [ -z "${version}" ]
then
echo "Hey, a version was not set, using latest tag...!
version="latest"
fi

#begin
cd ../
docker build -t dev:test1 .

#get the image ID from docker
image=`docker images | grep -i dev | grep -i test1 | sed 's/  */ /g' | cut -f 3 -d " "`

#tag and push to repo
$(aws ecr get-login --no-include-email --region eu-west-1)
docker tag  $image  $uri:$version
docker push $uri:$version
