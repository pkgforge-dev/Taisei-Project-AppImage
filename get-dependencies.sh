#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    boost    		    \
	cmake 	 		    \
	gamemode			\
    glad     		    \
    glslang  		    \
	hicolor-icon-theme  \
	libunibreak 		\
	libwebp  			\
    libzip   			\
	meson			    \
    mimalloc 			\
    opusfile 			\
	sdl3     			\
    shaderc

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini opus-mini

echo "Building cglm..."
echo "---------------------------------------------------------------"
REPO="https://github.com/recp/cglm"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --depth 1 "$REPO" ./cglm
echo "$VERSION" > ~/version

cmake -S ./cglm -B build -DCMAKE_INSTALL_PREFIX=/usr/ -DCMAKE_BUILD_TYPE=Release
cmake --build build --config release -j$(nproc)
cmake --install build

echo "Building Taisei Project..."
echo "---------------------------------------------------------------"
REPO="https://github.com/taisei-project/taisei"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of Taisei Project..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --recursive --depth 1 "$REPO" ./taisei
else
	echo "Making stable build of Taisei Project..."
	VERSION="$(git ls-remote --tags --refs "$REPO" | sed 's|.*refs/tags/||' | grep -E '^v[0-9]+(\.[0-9]+)*$' | sort -V | tail -n1 | sed 's/^v//')"
	git clone --branch v"$VERSION" --single-branch --recursive --depth 1 "$REPO" ./taisei
fi
echo "$VERSION" > ~/version

cd ./taisei && meson ./ build \
    -Dinstall_macos_bundle=disabled \
	-Dinstall_relocatable=enabled \
    -Dr_gles30=disabled \
    -Dshader_transpiler=disabled \
	-Dshader_transpiler_dxbc=disabled
meson compile -C build
meson install -C build
