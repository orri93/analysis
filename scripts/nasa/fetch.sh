#!/bin/bash

PROJECT_NAME="Fetch NASA data into tmp folder"

WGET=wget

# Resolve the Current Script Directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
# echo "SOURCE is '$SOURCE'"
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
if [ "$DIR" != "$RDIR" ]; then
  echo "DIR '$RDIR' resolves to '$DIR'"
fi
# echo "DIR is '$DIR'"
ROOT_DIR=`realpath "$DIR/../.."`

# Silent pushd and popd
silent_pushd () {
  command pushd "$@" > /dev/null
}
silent_popd () {
  command popd "$@" > /dev/null
}

echo "---------------------------------------------------------------------------"
echo "Script for the ${PROJECT_NAME}"
echo "${PROJECT_NAME} root directory is defined as ${ROOT_DIR}"

WP=${ROOT_DIR}/tmp/nasa/spdf/solar-orbiter/helio1day
echo "Entering ${WP}"
silent_pushd ${WP}
wget https://spdf.gsfc.nasa.gov/pub/data/solar-orbiter/helio1day/solo_helio1day_position_20200211_v01.cdf
echo "Leaving ${WP}"
silent_popd

echo "---------------------------------------------------------------------------"
