# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

Sparse_PV="7.10.1"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Sparse LU factorization for circuit simulation"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0/2"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="+cholmod debug doc static-libs test"
RESTRICT="!test? ( test ) mirror"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}
	>=sci-libs/amd-3.3.1
	>=sci-libs/btf-2.3.1
	>=sci-libs/colamd-3.3.1
	cholmod? ( >=sci-libs/cholmod-5.2.0 )
	virtual/blas"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DKLU_USE_CHOLMOD=$(usex cholmod)
		-DSUITESPARSE_DEMOS=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	./klu_simple || die "failed testing"
	./kludemo  < "${S}"/Matrix/1c.mtx || die "failed testing"
	./kludemo  < "${S}"/Matrix/arrowc.mtx || die "failed testing"
	./kludemo  < "${S}"/Matrix/arrow.mtx || die "failed testing"
	./kludemo  < "${S}"/Matrix/impcol_a.mtx || die "failed testing"
	./kludemo  < "${S}"/Matrix/w156.mtx || die "failed testing"
	./kludemo  < "${S}"/Matrix/ctina.mtx || die "failed testing"
	./kluldemo < "${S}"/Matrix/1c.mtx || die "failed testing"
	./kluldemo < "${S}"/Matrix/arrowc.mtx || die "failed testing"
	./kluldemo < "${S}"/Matrix/arrow.mtx || die "failed testing"
	./kluldemo < "${S}"/Matrix/impcol_a.mtx || die "failed testing"
	./kluldemo < "${S}"/Matrix/w156.mtx || die "failed testing"
	./kluldemo < "${S}"/Matrix/ctina.mtx || die "failed testing"
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

