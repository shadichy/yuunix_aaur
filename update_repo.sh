#!/bin/bash

arch=$(arch)

trap 'exit 1' EXIT

rm -rf $arch
mkdir -p $arch

# Building blissos-calamares
mkdir -p calamares
cd calamares
git clone https://github.com/Yuunix-Team/blissos-calamares
cp blissos-calamares/ci/APKBUILD .
abuild -rf
cd ..

# Building blissos-installer-data
git clone https://github.com/Yuunix-Team/blissos-installer
cd blissos-installer
abuild -rf
cd ..

# Getting packages
mirror=https://dl-cdn.alpinelinux.org/alpine/v3.18/community/
cd $arch
apk -X $mirror --allow-untrusted fetch kpmcore kpmcore-dev

# Indexing and Updating
apk index
git add $arch
git commit -am "repo update"
git push