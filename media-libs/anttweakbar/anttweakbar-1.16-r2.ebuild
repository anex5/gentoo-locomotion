# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="A library that adds an easy GUI into OpenGL applications"
HOMEPAGE="http://www.antisphere.com/Wiki/tools:anttweakbar?sb=tools"

SRC_URI="https://sourceforge.net/projects/anttweakbar/files/latest/download?source=dlp -> ${P}.zip"

KEYWORDS="~x86 ~amd64"
LICENSE="ZLIB"
SLOT="0"
IUSE=""

DEPEND="
	x11-libs/libX11:=
	x11-libs/libXext:=
	x11-libs/libXxf86vm:=
	virtual/libc
"
RDEPEND="$DEPEND"
RESTRICT="mirror test"

S="${WORKDIR}/AntTweakBar"

src_configure() {
	sed -i -e "s|^LIBS.*$|LIBS\t\t= -L/usr/lib64 -lGL -lX11 -lXxf86vm -lXext -lpthread -lm|g" \
		-e "s|^CXXCFG.*$||g" \
		-e "s|\$(AR) \$(OUT_DIR)/lib\$(TARGET)\$(AR_EXT) \$(OBJS) \$(LIBS)|\$(AR) \$(OUT_DIR)/lib\$(TARGET)\$(AR_EXT) \$(OBJS)|g" src/Makefile || die
}

src_compile() {
	cd src
	emake CC="$(tc-getCC)" FLAGS="${CFLAGS}" \
		LIBDIR="-L/usr/$(get_libdir)" || die "${P} could not be compiled"
}

src_install() {
	dolib.so lib/libAntTweakBar.so
	dosym libAntTweakBar.so ${EPREFIX}/usr/$(get_libdir)/libAntTweakBar.so.$(ver_cut 1)
	doheader include/AntTweakBar.h
}
