#!/bin/sh

echo "PREBUILD!"

rm output/target/etc/init.d/S40network || true

rm output/target/usr/bin/gapplication || true
rm output/target/usr/bin/gdbus || true
rm output/target/usr/bin/gio || true
rm output/target/usr/bin/gio-querymodules || true
rm output/target/usr/bin/gresource || true
rm output/target/usr/bin/gsettings || true

echo "export TERM=\"linux\"" >output/target/etc/profile.d/linuxterm.sh || true
echo "stty cols 80 rows 25" >>output/target/etc/profile.d/linuxterm.sh || true


