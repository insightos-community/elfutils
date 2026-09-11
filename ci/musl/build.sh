#!/bin/sh
set -eu
cd /work
mkdir -p logs prefix dist
exec > logs/build.log 2>&1
apk add --no-cache build-base git binutils patch argp-standalone bison bsd-compat-headers bzip2-dev flex-dev libtool linux-headers musl-fts-dev musl-libintl musl-legacy-error musl-obstack-dev xz-dev zlib-dev zstd-dev
apk info -v > logs/apk-packages.txt
cp -a /src source
cd source
for patchfile in /src/ci/musl/patches/*.patch; do patch -p1 < "$patchfile"; done
CFLAGS='-O2 -D_GNU_SOURCE -Wno-error -Wno-null-dereference' ./configure \
  --prefix=/work/prefix --libdir=/work/prefix/lib --disable-werror \
  --disable-nls --disable-libdebuginfod --disable-debuginfod --with-zstd \
  > /work/logs/configure.log 2>&1
make -C lib -j2 > /work/logs/compile.log 2>&1
make -C libelf -j2 >> /work/logs/compile.log 2>&1
make -C libelf install > /work/logs/install.log 2>&1
cc /src/ci/musl/test_elf.c -I/work/prefix/include -L/work/prefix/lib -lelf -o /work/test-elf
LD_LIBRARY_PATH=/work/prefix/lib /work/test-elf > /work/logs/tests.log 2>&1
cd /work
python /src/ci/musl/package.py
