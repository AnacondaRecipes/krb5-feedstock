#!/bin/bash
set -e

export CPPFLAGS="${CPPFLAGS/-DNDEBUG/} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ ${HOST} =~ .*linux.* ]]; then
  export LDFLAGS="$LDFLAGS -Wl,--disable-new-dtags"
fi

# https://github.com/conda-forge/bison-feedstock/issues/7
export M4="${BUILD_PREFIX}/bin/m4"

# Configure with standard options
CONFIGURE_ARGS="--prefix=${PREFIX}
               --host=${HOST}
               --build=${BUILD}
               --sysconfdir=${PREFIX}/etc
               --localstatedir=${PREFIX}/var
               --runstatedir=${PREFIX}/var/run
               --without-tcl
               --without-readline
               --with-libedit
               --with-crypto-impl=openssl
               --with-tls-impl=openssl
               --without-system-verto
               --disable-rpath
               --enable-shared
               --disable-static
               --enable-dns-for-realm
               --with-lmdb
               --without-ldap"

pushd src
  autoreconf -i
  ./configure ${CONFIGURE_ARGS}
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make install
popd 