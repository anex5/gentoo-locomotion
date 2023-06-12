# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Metapackage for a suite of sparse matrix tools"
HOMEPAGE="http://faculty.cse.tamu.edu/davis/suitesparse.html"

LICENSE="metapackage"
SLOT="0"

KEYWORDS="amd64 arm64 ppc ppc64 ~sparc x86"
IUSE="cuda doc lapack partition tbb"
DEPEND=""
RDEPEND="
	=sci-libs/suitesparseconfig-${PV}
	sci-libs/amd[doc?]
	sci-libs/btf
	sci-libs/camd[doc?]
	sci-libs/ccolamd
	sci-libs/cholmod[cuda?,doc?,partition?,lapack?]
	sci-libs/colamd
	sci-libs/cxsparse
	sci-libs/klu[doc?]
	sci-libs/ldl[doc?]
	sci-libs/spqr[doc?,partition?,tbb?]
	sci-libs/umfpack[doc?,cholmod]"
