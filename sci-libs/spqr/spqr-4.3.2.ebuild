# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib toolchain-funcs

Sparse_PV="7.10.1"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Multithreaded multifrontal sparse QR factorization library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="GPL-2+"
SLOT="0/4"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="cuda debug doc openmp static-libs test"
RESTRICT="!test? ( test ) mirror"

BDEPEND="
	virtual/pkgconfig
	doc? ( virtual/latex-base )
"
DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}[openmp?,cuda?]
	>=sci-libs/amd-3.3.3:=
	>=sci-libs/colamd-3.3.1:=
	>=sci-libs/cholmod-5.2.0:=[supernodal]
	virtual/blas"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && ( use openmp && tc-check-openmp )
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && ( use openmp && tc-check-openmp )
}

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DSPQR_USE_CUDA=$(usex cuda)
		-DSUITESPARSE_DEMOS=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	./qrsimple  < "${S}"/Matrix/ash219.mtx || die "failed testing"
	./qrsimplec < "${S}"/Matrix/ash219.mtx || die "failed testing"
	./qrsimple  < "${S}"/Matrix/west0067.mtx || die "failed testing"
	./qrsimplec < "${S}"/Matrix/west0067.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/a2.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/r2.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/a04.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/a2.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/west0067.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/c2.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/a0.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/lfat5b.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/bfwa62.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/LFAT5.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/b1_ss.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/bcspwr01.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/lpi_galenet.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/lpi_itest6.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/ash219.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/a4.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/s32.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/c32.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/lp_share1b.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/a1.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/GD06_theory.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/GD01_b.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/Tina_AskCal_perm.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/Tina_AskCal.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/GD98_a.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/Ragusa16.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/young1c.mtx || die "failed testing"
	./qrdemo < "${S}"/Matrix/lp_e226_transposed.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/a2.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/r2.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/a04.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/a2.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/west0067.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/c2.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/a0.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/lfat5b.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/bfwa62.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/LFAT5.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/b1_ss.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/bcspwr01.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/lpi_galenet.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/lpi_itest6.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/ash219.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/a4.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/s32.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/c32.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/lp_share1b.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/a1.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/GD06_theory.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/GD01_b.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/Tina_AskCal_perm.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/Tina_AskCal.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/GD98_a.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/Ragusa16.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/young1c.mtx || die "failed testing"
	./qrdemoc < "${S}"/Matrix/lp_e226_transposed.mtx || die "failed testing"
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
	cat >> "${T}/${PN^^}.pc" <<- EOF
# SuiteSparse_config, Copyright (c) 2012-2025, Timothy A. Davis.
# All Rights Reserved.
# SPDX-License-Identifier: BSD-3-clause

prefix=${EPREFIX}/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/$(get_libdir)
includedir=\${prefix}/include/suitesparse

Name: ${PN^^}
Description: ${DESCRIPTION}
Version: ${PV}
URL: ${HOMEPAGE}
Libs: -L\${libdir} -l${PN}
Libs.private: -lm
Cflags: -I\${includedir}
Requires: SuiteSparse_config
EOF

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}/${PN^^}.pc"


	use doc && einstalldocs

	use !static-libs &&	( find "${ED}" -name "*.a" -delete || die )

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}

