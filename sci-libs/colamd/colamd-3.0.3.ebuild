# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

Sparse_PV="7.0.1"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Column approximate minimum degree ordering algorithm"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="debug doc static-libs test"
RESTRICT="!test? ( test ) mirror"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}"
REPEND="${DEPEND}"

BDEPEND="
	virtual/pkgconfig
	doc? ( virtual/latex-base )
"
S="${WORKDIR}/${Sparse_P}/${PN^^}"

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DNSTATIC=$(usex !static-libs)
		-DDEMO=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	./colamd_example > colamd_example.out || die "failed to run test colamd_example"
	diff "${S}"/Demo/colamd_example.out colamd_example.out || die "failed testing colamd_example"
	./colamd_l_example > colamd_l_example.out || die "failed to run test colamd_l_example"
	diff "${S}"/Demo/colamd_l_example.out colamd_l_example.out || die "failed testing colamd_l_example"
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

