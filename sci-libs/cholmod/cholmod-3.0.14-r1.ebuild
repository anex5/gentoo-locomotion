# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal toolchain-funcs

DESCRIPTION="Sparse Cholesky factorization and update/downdate library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
#SRC_URI="http://202.36.178.9/sage/${P}.tar.bz2"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v5.8.1.tar.gz -> SuiteSparse-5.8.1.tar.gz"

LICENSE="LGPL-2.1+ modify? ( GPL-2+ ) matrixops? ( GPL-2+ )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="cuda doc +lapack +matrixops +modify +partition"

BDEPEND="virtual/pkgconfig
	doc? ( virtual/latex-base )"

DEPEND="
	sci-libs/amd
	sci-libs/colamd
	cuda? (
		dev-util/nvidia-cuda-toolkit
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

S=${WORKDIR}/SuiteSparse-5\.8\.1

PATCHES=(
	"${FILESDIR}/suitesparseconfig.mk.patch"
)

src_prepare() {
	default
	tc-export CC CXX F77 FC AR RANLIB
	use cuda && eapply "${FILESDIR}/cuda.patch"
	S=${WORKDIR}/SuiteSparse-5\.8\.1/${PN^^}
	multilib_copy_sources
}

multilib_src_compile() {
	OPTIMIZATION="" SUITESPARSE=$(pwd) \
	emake library || die "make failed"
}

multilib_src_install() {
	dolib.so lib/{lib${PN}.so.$(ver_cut 1-1),lib${PN}.so.$(ver_cut 1-3),lib${PN}.so} || die
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

	insinto /usr/include
	doins Include/{${PN}_supernodal.h,${PN}_partition.h,${PN}_modify.h,${PN}_matrixops.h,${PN}_io64.h,${PN}_function.h,${PN}_core.h,${PN}_config.h,${PN}_cholesky.h,${PN}_check.h,${PN}_camd.h,${PN}_blas.h,${PN}.h} || die

	use doc && einstalldocs

	# no static archives
	find "${D}" -name '*.la' -delete || die
}
