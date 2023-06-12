# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib toolchain-funcs cuda

MY_PV="7.0.1"

DESCRIPTION="Sparse Cholesky factorization and update/downdate library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
#SRC_URI="http://202.36.178.9/sage/${P}.tar.bz2"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${MY_PV}.tar.gz -> SuiteSparse-${MY_PV}.tar.gz"

LICENSE="LGPL-2.1+ modify? ( GPL-2+ ) matrixops? ( GPL-2+ )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE="cuda debug doc +lapack +matrixops +modify +partition static-libs"

BDEPEND="virtual/pkgconfig
	doc? ( virtual/latex-base )"

DEPEND="
	sci-libs/amd
	sci-libs/colamd
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
	)
	lapack? ( virtual/lapack )
	partition? (
		sci-libs/camd
		sci-libs/ccolamd
		|| (
			>=sci-libs/metis-5.1.0
			sci-libs/parmetis
		)
	)"
RDEPEND="${DEPEND}"
RESTRICT="mirror"

#S=${WORKDIR}/SuiteSparse-${MY_PV}
S=${WORKDIR}/SuiteSparse-${MY_PV}/${PN^^}

src_prepare() {
	tc-export CC CXX AR RANLIB
	#use cuda && eapply "${FILESDIR}/cuda.patch"
	multilib_copy_sources
	cmake_src_prepare
}

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DNSTATIC=$(usex !static-libs)
		-DGPU_BLAS=$(usex cuda)
		-DNPARTITION=$(usex !partition)
		-DNMODIFY=$(usex !modify)
		-DNMATRIXOPS=$(usex !matrixops)
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
	cat >> "${T}"/cholmod.pc <<- EOF
	prefix=${EPREFIX}/usr
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/$(get_libdir)
	includedir=\${prefix}/include

	Name: cholmod
	Description: Supernodal sparse Cholesky factorization and update/downdate
	Version: ${PV}
	URL: http://www.cise.ufl.edu/research/sparse/cholmod/
	Libs: -L\${libdir} -lcholmod
	Libs.private: -lm -lrt  -L/opt/cuda/lib64 -lcublas
	Cflags: -I\${includedir}
	Requires: suitesparseconfig
	Requires.private: blas lapack metis amd camd colamd ccolamd
	EOF

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}"/cholmod.pc

	use doc && einstalldocs

	# no static archives
	use !static-libs &&	find "${ED}" -name "*.a" -delete || die

	# strip .la files
	find "${D}" -name '*.la' -delete || die
}
