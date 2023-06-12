# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib toolchain-funcs

MY_PV="7.0.1"

DESCRIPTION="Library to order a sparse matrix prior to Cholesky factorization"
HOMEPAGE="http://faculty.cse.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${MY_PV}.tar.gz -> SuiteSparse-${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE="debug doc fortran static-libs"

S=${WORKDIR}/SuiteSparse-${MY_PV}/${PN^^}

BDEPEND="
	virtual/pkgconfig
	doc? ( virtual/latex-base )
"
DEPEND=">=sci-libs/suitesparseconfig-${MY_PV}"
REPEND="${DEPEND}"
RESTRICT="mirror"

src_prepare() {
	tc-export CC CXX AR RANLIB
	multilib_copy_sources
	cmake_src_prepare
}

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DNSTATIC=$(usex !static-libs)
	)
	cmake_src_configure
}

src_configure() {
	cmake-multilib_src_configure
}

multilib_src_compile() {
	cmake_src_compile
}

src_compile() {
	cmake-multilib_src_compile
}

multilib_src_install() {
	cmake_src_install
}

multilib_src_install_all() {
	cat >> "${T}"/${PN}.pc <<- EOF
	prefix=${EPREFIX}/usr
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/$(get_libdir)
	includedir=\${prefix}/include

	Name: COLAMD
	Description: Column Approximate Minimum Degree ordering
	Version: ${PV}
	URL: http://www.cise.ufl.edu/research/sparse/amd/
	Libs: -L\${libdir} -lcolamd
	Libs.private: -lm
	Cflags: -I\${includedir}
	Requires: suitesparseconfig
	EOF

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}"/${PN}.pc

	use doc && einstalldocs

	use !static-libs &&	find "${ED}" -name "*.a" -delete || die

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}

