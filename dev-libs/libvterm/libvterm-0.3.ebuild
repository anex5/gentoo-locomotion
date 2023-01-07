# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="An abstract library implementation of a VT220/xterm/ECMA-48 terminal emulator"
HOMEPAGE="https://www.leonerd.org.uk/code/libvterm/"
SRC_URI="https://www.leonerd.org.uk/code/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv ~x86 ~x64-macos"

BDEPEND="
	dev-lang/perl
	sys-devel/slibtool
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/libvterm-0.3.0-slibtool.patch"
)

_emake() {
	tc-export CC

	append-cflags -fPIC
	local myemakeargs=(
		"VERBOSE=1"
		"PREFIX=${EPREFIX}/usr"
		"LIBDIR=${EPREFIX}/usr/$(get_libdir)"
		"LIBTOOL=slibtool"
	)
	emake "${myemakeargs[@]}" "${@}"
}

src_compile() {
	_emake
}

src_install() {
	_emake DESTDIR="${D}" install

	find "${ED}" -name '*.la' -delete || die "Failed to prune libtool files"
	find "${ED}" -name '*.a' -delete || die
}
