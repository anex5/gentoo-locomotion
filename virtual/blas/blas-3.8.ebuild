# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="Virtual for FORTRAN 77 BLAS implementation"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~loong ~mips ~ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos"
IUSE="eselect-ldso"

RDEPEND="
	app-eselect/eselect-blas
	eselect-ldso? ( || (
		>=sci-libs/lapack-3.8[eselect-ldso]
		sci-libs/openblas[eselect-ldso]
		sci-libs/blis[eselect-ldso] ) )
"
DEPEND="${RDEPEND}"
