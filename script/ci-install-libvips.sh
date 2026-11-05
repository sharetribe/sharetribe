#!/bin/bash
#
# Build and install libvips from source for CI.
#
# Active Storage (Rails >= 7.1) refuses to boot with libvips < 8.13 because it
# cannot disable libvips's unfuzzed operations. Ubuntu 22.04 (the base of the
# CircleCI ruby image) only ships libvips 8.12, so build a newer one.
#
# The build is installed into $LIBVIPS_PREFIX so that CircleCI can cache it
# between runs. Only the (fast) apt install, ld.so configuration and version
# check run when the cached build is present.
#
# Image formats enabled: JPEG, PNG, WebP, TIFF, SVG, GIF (GIF saving needs
# both libimagequant and libcgif).

set -eo pipefail

LIBVIPS_VERSION="${LIBVIPS_VERSION:-8.15.5}"
LIBVIPS_PREFIX="${LIBVIPS_PREFIX:-$HOME/libvips}"

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential meson ninja-build pkg-config \
  libglib2.0-dev libexpat1-dev \
  libjpeg-turbo8-dev libpng-dev libwebp-dev libtiff5-dev libexif-dev \
  librsvg2-dev liblcms2-dev libimagequant-dev libcgif-dev

installed_version() {
  "$LIBVIPS_PREFIX/bin/vips" --version 2>/dev/null | sed -n 's/^vips-\([0-9.]*\).*/\1/p'
}

if [[ "$(installed_version)" == "$LIBVIPS_VERSION" ]] ; then
  echo "libvips $LIBVIPS_VERSION already installed in $LIBVIPS_PREFIX"
else
  echo "Building libvips $LIBVIPS_VERSION"
  build_dir="$(mktemp -d)"
  curl -sfSL "https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.xz" \
    | tar -xJ -C "$build_dir"
  pushd "$build_dir/vips-${LIBVIPS_VERSION}"
  meson setup build \
    --prefix="$LIBVIPS_PREFIX" \
    --libdir=lib \
    --buildtype=release \
    -Dintrospection=disabled \
    -Dmodules=disabled \
    -Ddeprecated=false \
    -Dexamples=false \
    -Dcplusplus=false
  ninja -C build
  rm -rf "$LIBVIPS_PREFIX"
  ninja -C build install
  popd
  rm -rf "$build_dir"
fi

# Make the library visible to the dynamic linker (ruby-vips loads it via FFI).
echo "$LIBVIPS_PREFIX/lib" | sudo tee /etc/ld.so.conf.d/libvips.conf >/dev/null
sudo ldconfig

"$LIBVIPS_PREFIX/bin/vips" --version
