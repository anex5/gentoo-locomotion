# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="A library that adds an easy GUI into OpenGL applications to interactively tweak them on-screen"
HOMEPAGE="http://www.antisphere.com/Wiki/tools:anttweakbar?sb=tools"

SRC_URI="https://sourceforge.net/projects/anttweakbar/files/latest/download?source=dlp -> ${P}.zip"

KEYWORDS="~x86 ~amd64"
LICENSE="ZLIB"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="$DEPEND"
RESTRICT="mirror"

S="${WORKDIR}/AntTweakBar"

src_compile() {
	cd src
	emake || die "${P} could not be compiled"
}

src_install() {
	dolib.so lib/libAntTweakBar.so
	dolib.so lib/libAntTweakBar.so.1
	insinto /usr/include
	doins include/AntTweakBar.h
}
