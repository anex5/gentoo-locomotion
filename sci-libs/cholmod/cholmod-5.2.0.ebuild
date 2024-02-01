# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cuda cmake-multilib toolchain-funcs

Sparse_PV="7.6.0"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Sparse Cholesky factorization and update/downdate library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="LGPL-2.1+ modify? ( GPL-2+ ) matrixops? ( GPL-2+ )"
SLOT="0/4"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="+cholesky cuda camd +check debug doc fortran openmp +matrixops +modify +partition +supernodal test static-libs"
RESTRICT="!test? ( test )"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}
	>=sci-libs/amd-3.3.1
	>=sci-libs/colamd-3.3.1
	supernodal? ( virtual/lapack )
	partition? (
		>=sci-libs/camd-3.3.1
		>=sci-libs/ccolamd-3.3.1
		>=sci-libs/metis-5.2.1
	)
	cuda? (
		dev-util/nvidia-cuda-toolkit
		x11-drivers/nvidia-drivers
	)"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

REQUIRED_USE="supernodal? ( cholesky )
	modify? ( cholesky )
	matrixops? ( check )
	partition? ( camd )
	test? ( cholesky matrixops supernodal )"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

RESTRICT="mirror"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {
	use cuda && cuda_src_prepare
	multilib_copy_sources
	cmake_src_prepare
}

multilib_src_configure() {
	# Not that "N" prefixed options are negative options
	# so they need to be turned OFF if you want that option.
	# Fortran is turned off as it is only used to compile (untested) demo programs.
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)
	local mycmakeargs=(
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DCHOLMOD_USE_CUDA=$(usex cuda)
		-DCHOLMOD_USE_OPENMP=$(usex openmp)
		-DSUITESPARSE_HAS_FORTRAN=$(usex fortran)
		-DCHOLMOD_CAMD=$(usex camd)
		-DCHOLMOD_CHECK=$(usex check)
		-DCHOLMOD_CHOLESKY=$(usex cholesky)
		-DCHOLMOD_MATRIXOPS=$(usex matrixops)
		-DCHOLMOD_MODIFY=$(usex modify)
		-DCHOLMOD_PARTITION=$(usex partition)
		-DCHOLMOD_SUPERNODAL=$(usex supernodal)
		-DSUITESPARSE_DEMOS=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	./cholmod_demo   < "${S}"/Demo/Matrix/bcsstk01.tri || die "failed testing"
	./cholmod_l_demo < "${S}"/Demo/Matrix/bcsstk01.tri || die "failed testing"
	./cholmod_demo   < "${S}"/Demo/Matrix/lp_afiro.tri || die "failed testing"
	./cholmod_l_demo < "${S}"/Demo/Matrix/lp_afiro.tri || die "failed testing"
	./cholmod_demo   < "${S}"/Demo/Matrix/can___24.mtx || die "failed testing"
	./cholmod_l_demo < "${S}"/Demo/Matrix/can___24.mtx || die "failed testing"
	./cholmod_demo   < "${S}"/Demo/Matrix/c.tri || die "failed testing"
	./cholmod_l_demo < "${S}"/Demo/Matrix/c.tri || die "failed testing"
	./cholmod_simple < "${S}"/Demo/Matrix/c.tri || die "failed testing"
	./cholmod_simple < "${S}"/Demo/Matrix/can___24.mtx || die "failed testing"
	./cholmod_simple < "${S}"/Demo/Matrix/bcsstk01.tri || die "failed testing"
}

multilib_src_install() {
	if use doc; then
		pushd "${S}/Doc"
		rm -rf *.pdf
		emake
		popd
		DOCS="${S}/Doc/*.pdf"
	fi
	cmake_src_install
}

multilib_src_install_all() {
	# no static archives
	use !static-libs &&	( find "${ED}" -name "*.a" -delete || die )

	# strip .la files
	find "${D}" -name '*.la' -delete || die
}
