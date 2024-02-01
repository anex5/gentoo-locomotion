# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED="fortran"
inherit cmake-multilib fortran-2

Sparse_PV="7.6.0"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="BTF is a library for permuting a matrix into block upper triangular form"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0/2"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="debug doc fortran static-libs test"
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
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DSUITESPARSE_HAS_FORTRAN=$(usex fortran)
		-DSUITESPARSE_DEMOS=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	local demofiles=(
		btf_demo
		btf_l_demo
		btf_demo2
		btf_simple
	)
	if use fortran; then
		demofiles+=(
			btf_f77simple
			btf_f77demo
		)
	fi
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

