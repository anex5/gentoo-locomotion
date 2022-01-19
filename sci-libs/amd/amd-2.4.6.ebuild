# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal toolchain-funcs

MY_PV="5.10.1"

DESCRIPTION="Library to order a sparse matrix prior to Cholesky factorization"
HOMEPAGE="http://faculty.cse.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${MY_PV}.tar.gz -> SuiteSparse-${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc fortran static-libs"

S=${WORKDIR}/SuiteSparse-${MY_PV}/${PN^^}

BDEPEND="virtual/pkgconfig
	doc? ( virtual/latex-base )
	fortran? ( virtual/fortran )"
DEPEND=">=sci-libs/suitesparseconfig-${MY_PV}"
REPEND="${DEPEND}"
RESTRICT="mirror"

src_prepare() {
	default
	tc-export CC CXX F77 FC AR RANLIB
	multilib_copy_sources
}

multilib_src_compile() {
	#Do not build demo
	sed -i -e '/( cd Demo   ; $(MAKE) fortran )/d' Makefile || die

	export OPTIMIZATION=""
	export JOBS=""
	export SUITESPARSE=$(pwd)
	export INSTALL_LIB=${SUITESPARSE}/Lib
	emake config || die "make failed"
	emake library || die "make failed"
	use fortran && ( emake fortran || die "make failed" )
	use static-libs && ( emake static || die "make failed" )
}

multilib_src_install() {
	dolib.so Lib/{libamd.so.$(ver_cut 1-1),libamd.so.$(ver_cut 1-3),libamd.so} || die
	use fortran && ( dolib.so Lib/libamdf77.a || die )
	use static-libs && ( dolib.a Lib/libamd.a || die )
}

multilib_src_install_all() {
	cat >> "${T}"/amd.pc <<- EOF
	prefix=${EPREFIX}/usr
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/$(get_libdir)
	includedir=\${prefix}/include

	Name: AMD
	Description: Approximate Minimum Degree ordering
	Version: ${PV}
	URL: http://www.cise.ufl.edu/research/sparse/amd/
	Libs: -L\${libdir} -lamd
	Libs.private: -lm
	Cflags: -I\${includedir}
	Requires: suitesparseconfig
	EOF

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}"/amd.pc

	insinto /usr/include
	doins Include/amd.h || die
	doins Include/amd_internal.h || die

	use doc && einstalldocs

	use !static-libs &&	find "${ED}" -name "*.a" -delete || die

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}

