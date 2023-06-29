# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs multilib-minimal

DESCRIPTION="Common configurations for all packages in suitesparse"
HOMEPAGE="http://faculty.cse.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${PV}.tar.gz -> SuiteSparse-${PV}.gh.tar.gz"

# No licensing restrictions apply to this file or to the SuiteSparse_config directory.
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 sparc x86 ~amd64-linux ~x86-linux"
IUSE="static-libs"
RESTRICT="mirror"

S=${WORKDIR}/SuiteSparse-${PV}/SuiteSparse_config

PATCHES=(
	"${FILESDIR}/suitesparseconfig.mk.patch"
)

src_prepare() {
	default
	tc-export CC CXX AR RANLIB
	multilib_copy_sources
}

multilib_src_compile() {
	#sed -i -e '//d' Lib/Makefile || die "sed failed"
	SUITESPARCE="$(pwd)" OPTIMIZATION="" AUTOCC=no emake library || die "make failed"
}

multilib_src_install() {
	if multilib_is_native_abi; then
		use static-libs && ( dolib.a libsuitesparseconfig.a || die )
	fi
}

multilib_src_install_all() {

	cat >> "${T}"/suitesparseconfig.pc <<- EOF
	prefix=${EPREFIX}/usr
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/$(get_libdir)
	includedir=\${prefix}/include

	Name: SuiteSparse_config
	Description: Common configurations for all packages in suitesparse
	Version: ${PV}
	Cflags: -I\${includedir}
	Libs: -L\${libdir} -lsuitesparseconfig
	EOF

	insinto /usr/include
	doins SuiteSparse_config.h || die

	dolib.so ../lib/{lib${PN}.so.$(ver_cut 1-1),lib${PN}.so.$(ver_cut 1-3),lib${PN}.so} || die

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}"/suitesparseconfig.pc

	einstalldocs

	if ! use static-libs; then
		find "${ED}" -name "*.a" -delete || die
	fi

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}
