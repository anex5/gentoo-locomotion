# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cuda multilib-minimal toolchain-funcs

Sparse_PV="5.8.1"

DESCRIPTION="Sparse Cholesky factorization and update/downdate library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${Sparse_PV}.tar.gz -> SuiteSparse-${Sparse_PV}.gh.tar.gz"

LICENSE="LGPL-2.1+ modify? ( GPL-2+ ) matrixops? ( GPL-2+ )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE="cuda doc +lapack +matrixops +modify +partition static-libs"

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

S=${WORKDIR}/SuiteSparse-${Sparse_PV}

PATCHES=(
	"${FILESDIR}/suitesparseconfig.mk.patch"
    "${FILESDIR}/fix_typos.patch"
    "${FILESDIR}/fix_feenableexcept.patch"
)

src_prepare() {
	default
	tc-export CC CXX F77 FC AR RANLIB
	if use cuda; then
		eapply "${FILESDIR}/cuda.patch"
		cuda_src_prepare
	fi
	S=${WORKDIR}/SuiteSparse-${Sparse_PV}/${PN^^}
	multilib_copy_sources
}

multilib_src_compile() {
	local cconfig=""
	use cuda && cconfig+="-DGPU_BLAS "
	#use cuda && cconfig+="-DNVCCFLAGS=\"$(cuda_gccdir -f)\/$(tc-getCC)\" "
	use partition || cconfig+="-DNPARTITION "
	use modify || cconfig+="-DNMODIFY "
	use matrixops || cconfig+="-DNMATRIXOPS "
	if use lapack; then
		blas_libs="$($(tc-getPKG_CONFIG) --libs blas)"
		lapack_libs=$($(tc-getPKG_CONFIG) --libs lapack)
	fi

	OPTIMIZATION="" SUITESPARSE=$(pwd) \
	#CHOLMOD_CONFIG="$cconfig" \
	BLAS="$blas_libs" LAPACK="$lapack_libs" \
	emake library || die "make failed"
}

multilib_src_install() {
	dolib.so ../lib/{lib${PN}.so.$(ver_cut 1-1),lib${PN}.so.$(ver_cut 1-3),lib${PN}.so} || die
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
	use !static-libs &&	find "${ED}" -name "*.a" -delete || die

	# strip .la files
	find "${D}" -name '*.la' -delete || die
}
