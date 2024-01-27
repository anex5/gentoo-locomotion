# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Metapackage for a suite of sparse matrix tools"
HOMEPAGE="https://github.com/DrTimothyAldenDavis/SuiteSparse"

LICENSE="metapackage"
SLOT="0"

KEYWORDS="amd64 arm64 ppc ppc64 ~sparc x86"
IUSE="cuda cholmod doc lapack openmp partition tbb"
DEPEND=""
RDEPEND="
	=sci-libs/suitesparseconfig-${PV}[cuda?,openmp?]
	>=sci-libs/amd-3.3.1[doc?]
	>=sci-libs/btf-2.3.1[doc?]
	>=sci-libs/camd-3.3.1[doc?]
	>=sci-libs/ccolamd-3.3.1[doc?]
	cholmod? ( >=sci-libs/cholmod-5.2.0[cuda?,doc?,partition?,lapack?] )
	>=sci-libs/colamd-3.3.1[doc?]
	>=sci-libs/cxsparse-4.3.1[doc?]
	>=sci-libs/klu-2.3.2[doc?]
	>=sci-libs/ldl-3.3.1[doc?]
	>=sci-libs/spex-2.3.2[doc?]
	>=sci-libs/spqr-4.3.2[doc?]
	>=sci-libs/umfpack-6.3.2[doc?,cholmod?]
"
