# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

Sparse_PV="7.10.1"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Library to order a sparse matrix prior to Cholesky factorization"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0/3"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="doc debug test static-libs"
RESTRICT="!test? ( test )"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DSUITESPARSE_DEMOS=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	local demofiles=(
		camd_demo
		camd_l_demo
		camd_demo2
		camd_simple
	)
	for i in ${demofiles[@]}; do
		./"${i}" > "${i}.out" || die "failed to run test ${i}"
		diff "${S}/Demo/${i}.out" "${i}.out" || die "failed testing ${i}"
	done
	einfo "All tests passed"
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
	use doc && einstalldocs

	use !static-libs &&	( find "${ED}" -name "*.a" -delete || die )

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}

