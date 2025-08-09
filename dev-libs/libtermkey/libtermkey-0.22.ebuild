# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit flag-o-matic toolchain-funcs

DESCRIPTION="Library for easy processing of keyboard entry from terminal-based programs"
HOMEPAGE="http://www.leonerd.org.uk/code/libtermkey/"
SRC_URI="http://www.leonerd.org.uk/code/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~riscv x86 ~x64-macos"
IUSE="demos man pgo static-libs"

RDEPEND="dev-libs/unibilium:="
BDEPEND="
	sys-devel/slibtool
	virtual/pkgconfig
"
DEPEND="
	demos? ( dev-libs/glib:2 )
"

src_prepare() {
	default

	sed -e 's/LIBTOOL ?= libtool/LIBTOOL ?= rlibtool/' \
		-e 's|PREFIX=/usr/local|PREFIX=/usr|' \
		-e "s|-rpath \$\(LIBDIR\)|-rpath ${EROOT}/usr/$(get_libdir)|" \
		-i Makefile || die

	if ! use demos; then
		sed -e '/^all:/s:$(DEMOS)::' -i Makefile || die
	fi
}

_emake() {
	local myemakeargs=(
		"VERBOSE=1"
		"PROFILE=$(usex pgo 1 0)"
		"CC=$(tc-getCC)"
		"LIBDIR=/usr/$(get_libdir)"
		"INCDIR=/usr/include"
	)
	tc-export_build_env
	emake "${myemakeargs[@]}" "$@"
}

src_compile() {
	_emake all
}

src_install() {
	_emake DESTDIR="${D}" install-lib install-inc
	use man && _emake DESTDIR="${D}" install-man

	use static-libs || rm "${ED}"/usr/$(get_libdir)/${PN}.a || die
}
