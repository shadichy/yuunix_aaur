#!/bin/bash

arch=$(arch)

trap 'exit 1' EXIT

rm -rf $arch ~/packages
mkdir -p $arch tmp

cd tmp

# Building blissos-calamares
mkdir -p calamares
cd calamares
git clone --depth 1 https://github.com/Yuunix-Team/blissos-calamares
cp blissos-calamares/ci/APKBUILD .
## Temporarily disable Bcachefs
find blissos-calamares/src/ -type f -exec sed -i -r 's|(.*Bcachefs.*)|\/\/\1|g' {} +
abuild -r
cd ..

# Building blissos-installer-data
git clone --depth 1 https://github.com/Yuunix-Team/blissos-installer-alpine
cd blissos-installer-alpine
abuild -r
cd ..

cd ..

# Getting packages
mirror=https://dl-cdn.alpinelinux.org/alpine/v3.18/community/
cd $arch
apk -X $mirror --allow-untrusted --no-cache --force-refresh --root /tmp fetch kpmcore kpmcore-dev

# Indexing and Updating
find ~/packages -type f -iname "*.apk" -exec cp -t . {} +
apk index -vU -o APKINDEX.tar.gz *.apk
git add $arch
git commit -am "repo update"
git push