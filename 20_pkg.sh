#!/bin/bash
pkgs="nvidia-dkms nvidia-utils"

cat /usr/lib/modules/*/pkgbase | while read krnl; do
    pkgs="${krnl}-headers ${pkgs}"
done

echo ${pkgs}
#sudo pacman -Sy --noconfirm ${pkgs}
