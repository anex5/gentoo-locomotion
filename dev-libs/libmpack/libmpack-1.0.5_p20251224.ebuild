# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs

DESCRIPTION="Simple implementation of msgpack in C"
HOMEPAGE="https://github.com/libmpack/libmpack"
COMMIT="c1f28db8df877a036fefc848b8fdbe0923f72c11"
SRC_URI="https://github.com/${PN}/${PN}/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 ppc ppc64 riscv sparc x86 x64-macos"

BDEPEND="
	dev-build/slibtool
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.5-libtool.patch # 778899
)

src_prepare() {
	default

	# Respect users CFLAGS
	sed -e 's/-ggdb//g' -i Makefile.in || die
	sed -e 's/-O[0-9]//g' -i .config/release.mk || die
	sed -r 'a\#include <stdbool\.h>' -i src/conv.h || die

	eautoreconf
}

_emake() {
	local myemakeargs=(
		"VERBOSE=1"
		"PREFIX=${EPREFIX}/usr"
		"HOST_CC=$(tc-getBUILD_CC)"
		"HOST_CFLAGS=${BUILD_CPPFLAGS} ${BUILD_CFLAGS}"
		"HOST_LDFLAGS=${BUILD_LDFLAGS}"
		"CC=$(tc-getCC)"
		"LD=$(tc-getLD)"
		"config=release"
		"LIBDIR=${EPREFIX}/usr/$(get_libdir)"
		"INCDIR=${EPREFIX}/usr/include"
	)

	emake "${myemakeargs[@]}" "${@}"
}

src_compile() {
	_emake lib-bin
}

src_test() {
	_emake XLDFLAGS="-shared" test
}

src_install() {
	_emake "DESTDIR=${D}" "XLDFLAGS=-shared" install

	if [[ ${CHOST} == *-darwin* ]] ; then
		local file="libmpack.0.0.0.dylib"
		install_name_tool \
			-id "${EPREFIX}/usr/$(get_libdir)/${file}" \
			"${ED}/usr/$(get_libdir)/${file}" \
			|| die "Failed to adjust install_name"
	fi

	find "${ED}" -name '*.la' -delete || die
}
