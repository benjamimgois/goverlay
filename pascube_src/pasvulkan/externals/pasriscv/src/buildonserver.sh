#!/bin/bash

#echo 1 > /home/bero/www/pasriscv/building.txt

CWD=$(pwd)

SWD="/home/bero/GitHub/pasriscv/src/"

cd "$SWD"

/home/bero/fpcupdeluxe/lazarus/lazbuild --primary-config-path=/home/bero/fpcupdeluxe/config_lazarus -B /home/bero/GitHub/pasriscv/src/PasRISCVTest.lpi || { echo 'Failed' ; cd "$CWD"; exit 1; }
patchelf --set-rpath "\$ORIGIN" /home/bero/GitHub/pasriscv/bin/PasRISCVTest

cd "$SWD"

#./builddeb.sh || { echo 'Failed' ; cd "$CWD"; exit 1; }

cd "$SWD"

#./buildtargz.sh || { echo 'Failed' ; cd "$CWD"; exit 1; }

cd "$SWD"

#./buildappimage.sh || { echo 'Failed' ; cd "$CWD"; exit 1; }

cd "$SWD"

#cp -f /home/bero/git/pasriscv/distribution/deb/pasriscv.deb /home/bero/www/pasriscv/pasriscv.deb

#cp -f /home/bero/git/pasriscv/distribution/targz/pasriscv.tar.gz /home/bero/www/pasriscv/pasriscv.tar.gz

#cp -f /home/bero/git/pasriscv/distribution/appimage/pasriscv-gtk2/pasriscv-gtk2-latest-x86_64.AppImage /home/bero/www/pasriscv/pasriscv-gtk2-latest-x86_64.AppImage

#cp -f /home/bero/git/pasriscv/distribution/appimage/pasriscv-qt5/pasriscv-qt5-latest-x86_64.AppImage /home/bero/www/pasriscv/pasriscv-qt5-latest-x86_64.AppImage

cd "$CWD"

echo 'Done!'

#echo 0 > /home/bero/www/pasriscv/building.txt

