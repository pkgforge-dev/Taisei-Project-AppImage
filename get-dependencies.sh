#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    boost    \
    glad     \
    glslang  \
    sdl3     \
    libzip   \
    mimalloc \
    opusfile \
    shaderc

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

# Comment this out if you need an AUR package
make-aur-package cglm

if [ "${DEVEL_RELEASE-}" = 1 ]; then
	package=taisei-git
else
	package=taisei
fi
make-aur-package "$package"
pacman -Q "$package" | awk '{print $2; exit}' > ~/version
