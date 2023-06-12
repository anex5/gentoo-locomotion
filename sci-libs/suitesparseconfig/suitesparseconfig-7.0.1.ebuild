# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib toolchain-funcs

DESCRIPTION="Common configurations for all packages in suitesparse"
HOMEPAGE="http://faculty.cse.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${PV}.tar.gz -> SuiteSparse-${PV}.tar.gz"

# No licensing restrictions apply to this file or to the SuiteSparse_config directory.
LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 sparc x86"
IUSE="doc debug static-libs"
RESTRICT="mirror"

S=${WORKDIR}/SuiteSparse-${PV}/SuiteSparse_config

src_prepare() {
	tc-export CC CXX AR RANLIB
	multilib_copy_sources
	cmake_src_prepare
}

multilib_src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	local mycmakeargs=(
		-DBLA_VENDOR=Generic
		-DALLOW_64BIT_BLAS=ON
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

	if multilib_is_native_abi; then
		use static-libs && ( dolib.a libsuitesparseconfig.a || die )
	fi
}

multilib_src_install_all() {

	cat >> "${T}"/suitesparseconfig.pc <<- EOF
	prefix=${EPREFIX}/usr
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/$(get_libdir)
	includedir=\${prefix}/include

	Name: SuiteSparse_config
	Description: Common configurations for all packages in suitesparse
	Version: ${PV}
	Cflags: -I\${includedir}
	Libs: -L\${libdir} -lsuitesparseconfig
	EOF

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}"/suitesparseconfig.pc

	use doc && einstalldocs

	if ! use static-libs; then
		find "${ED}" -name "*.a" -delete || die
	fi

	# strip .la files
	find "${ED}" -name '*.la' -delete || die
}
