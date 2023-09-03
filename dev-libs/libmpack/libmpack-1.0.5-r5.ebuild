# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs

DESCRIPTION="Simple implementation of msgpack in C"
HOMEPAGE="https://github.com/libmpack/libmpack"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~riscv ~sparc ~x86 ~x64-macos"

BDEPEND="
	sys-devel/slibtool
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${P}-libtool.patch # 778899
)

src_prepare() {
	default

	# Respect users CFLAGS
	sed -e 's/-ggdb//g' -i Makefile.in || die
	sed -e 's/-O[0-9]//g' -i .config/release.mk || die

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
		"LIBTOOL=slibtool"
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
