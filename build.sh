#!/bin/bash

set -e

msg() {
  echo
  echo -e "\033[1m$1\033[0m"
}

BUILD_DIR=./build
DOWNLOAD_URL="https://copy.com/install/linux/Copy.tgz"
DATE=`LC_TIME="us" date "+%a, %d %b %Y %T %z"`

msg "Getting maintainer info ..."
if [ -z "$MAINTAINER" ]; then
  echo "No maintainer name given, asking ..."
  echo -n "Enter maintainer name: "
  read MAINTAINER
fi
if [ -z "$EMAIL" ]; then
  echo "No maintainer email given, asking ..."
  echo -n "Enter maintainer email: "
  read EMAIL
fi
USERID="$MAINTAINER <$EMAIL>"
echo "Maintainer is $USERID"

msg "Installing dependencies ..."
BUILDDEPS="build-essential debhelper fakeroot curl wget"
dpkg -s $BUILDDEPS >/dev/null || sudo apt-get install $BUILDDEPS

msg "Changing to working directory ..."
pushd `dirname $0`

msg "Changing to build dir ..."
[ -d $BUILD_DIR ] || mkdir $BUILD_DIR
cd $BUILD_DIR

msg "Getting filename and version ..."
FILENAME=`curl -s -I $DOWNLOAD_URL | grep "Content-Disposition: attachment; filename=" | cut -d'"' -f 2`
VERSION=`echo $FILENAME | sed -rn 's/^copy_agent-([[:digit:]\.]*).tgz$/\1/p'`
echo "Filename: $FILENAME"
echo "Version: $VERSION"

if [ -e $FILENAME ]; then
  echo "File $FILENAME already exists, skipping download."
else
  msg "Downloading $FILENAME ..."
  curl -o $FILENAME $DOWNLOAD_URL
fi

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

msg "Successfully built:"
cd ..
ls -al copy-agent_$VERSION*.deb

popd