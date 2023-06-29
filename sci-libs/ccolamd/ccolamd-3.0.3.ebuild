# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

Sparse_PV="7.0.1"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Constrained Column approximate minimum degree ordering algorithm"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0/3"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="debug doc static-libs test"
RESTRICT="!test? ( test ) mirror"

BDEPEND="
	virtual/pkgconfig
	doc? ( virtual/latex-base )
"
DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}"
REPEND="${DEPEND}"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DNSTATIC=$(usex static-libs OFF ON)
		-DDEMO=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	./ccolamd_example > ccolamd_example.out || die "failed to run test ccolamd_example"
	diff "${S}"/Demo/ccolamd_example.out ccolamd_example.out || die "failed testing ccolamd_example"
	./ccolamd_l_example > ccolamd_l_example.out || die "failed to run test ccolamd_l_example"
	diff "${S}"/Demo/ccolamd_l_example.out ccolamd_l_example.out || die "failed testing ccolamd_l_example"
}

multilib_src_install() {
	if use doc; then
		pushd "${S}/Doc"
		emake clean
		rm -rf *.pdf
		emake
		popd
		DOCS="${S}/Doc/*.pdf"
	fi
	cmake_src_install
}

multilib_src_install_all() {
	cat >> "${T}"/ccolamd.pc <<- EOF
	prefix=${EPREFIX}/usr
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/$(get_libdir)
	includedir=\${prefix}/include

	Name: CCOLAMD
	Description: Constrained Approximate Minimum Degree Column ordering
	Version: ${PV}
	URL: http://www.cise.ufl.edu/research/sparse/amd/
	Libs: -L\${libdir} -lccolamd
	Libs.private: -lm
	Cflags: -I\${includedir}
	Requires: suitesparseconfig
	EOF

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}"/ccolamd.pc

	use doc && einstalldocs

	use !static-libs &&	find "${ED}" -name "*.a" -delete || die

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}

