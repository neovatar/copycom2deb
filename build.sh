#!/bin/bash

set -e

msg() {
  echo
  echo -e "\033[1m$1\033[0m"
}

BUILD_DIR=./build
DOWNLOAD_URL="https://copy.com/install/linux/Copy.tgz"
USERID="Thomas Seliger <ts@seliger.it>"
DATE=`LC_TIME="us" date "+%a, %d %b %Y %T %z"`

msg "Installing dependencies ..."
sudo apt-get install build-essential debhelper fakeroot curl wget

msg "Changing to working directory ..."
pushd `dirname $0`

msg "Changing to build dir ..."
[ -d $BUILD_DIR ] || mkdir $BUILD_DIR
cd $BUILD_DIR

msg "Getting filename and version ..."
FILENAME=`curl -s -I $DOWNLOAD_URL | grep "Content-Disposition: inline; filename=" | cut -d'"' -f 2`
VERSION=`echo $FILENAME | sed -rn 's/^copy_agent-([[:digit:]\.]*).tgz$/\1/p'`
echo "Filename: $FILENAME"
echo "Version: $VERSION"

msg "Downloading $DOWNLOAD_URL ..."
wget -N $DOWNLOAD_URL
cp Copy.tgz $FILENAME

msg "Extracting agent ..."
tar xfvz $FILENAME

msg "Getting architecture ..."
ARCH=`dpkg --print-architecture`
echo "Architecture: $ARCH"

msg "Preparing debian build dir ..."
ARCHDIR="x86"
[ "$ARCH" = "amd64" ] && ARCHDIR="x86_64"
DEBBUILD=copy-agent-$VERSION
[ -d $DEBBUILD ] && rm -rf $DEBBUILD
mkdir -p $DEBBUILD/copy-agent
cp -r copy/$ARCHDIR/* $DEBBUILD/copy-agent
cp -r ../debian $DEBBUILD

msg "Replacing build specific variables ..."
cd $DEBBUILD/debian
SEDFILE=./replace.sed

cat <<EOF > $SEDFILE
s/%%USER%%/$USERID/g
s/%%VERSION%%/$VERSION/g
s/%%DATE%%/$DATE/g
EOF

for ITEM in changelog control copyright
do
  sed -f $SEDFILE -i $ITEM
done

msg "Starting build ..."
cd ..
dpkg-buildpackage -rfakeroot


#echo "Copying debian files"
#cp -r ../debian ./libpam-google-authenticator-$VERSION

# echo "Starting build"
# cd ./libpam-google-authenticator-$VERSION
# dpkg-buildpackage -rfakeroot
# cd ..

popd