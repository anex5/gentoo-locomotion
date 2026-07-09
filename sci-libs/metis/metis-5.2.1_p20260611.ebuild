# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A package for unstructured serial graph partitioning"
HOMEPAGE="https://github.com/KarypisLab/METIS"
COMMIT="272d4a91c5f66c92327493339a476c553ebf1f5d"
SRC_URI="https://github.com/KarypisLab/METIS/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
S="${WORKDIR}/METIS-${COMMIT}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~x86"
IUSE="doc double-precision examples index64 openmp static-libs"

DEPEND="sci-libs/gklib"
RDEPEND="${DEPEND}"
RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}"/${PN}-5.2.1_p20260223-respect-user-flags.patch
	# https://github.com/KarypisLab/METIS/pull/52 Bug 905822
	"${FILESDIR}"/${PN}-5.2.1-add-gklib-as-required.patch
)

src_prepare() {
	local idxwidth realwidth

	if use index64; then
		idxwidth="#define IDXTYPEWIDTH 64"
	else
		idxwidth="#define IDXTYPEWIDTH 32"
	fi

	if use double-precision; then
		realwidth="#define REALTYPEWIDTH 64"
	else
		realwidth="#define REALTYPEWIDTH 32"
	fi

	cmake_src_prepare

	# From Makefile
	mkdir -p build/xinclude || die
	echo ${idxwidth} > build/xinclude/metis.h || die
	echo ${realwidth} >> build/xinclude/metis.h || die
	cat include/metis.h >> build/xinclude/metis.h || die
	cp include/CMakeLists.txt build/xinclude || die
}

src_configure() {
	local mycmakeargs=(
		-DGKLIB_PATH="${S}"/GKlib
		-DSHARED="$(usex static-libs OFF ON)"
		-DOPENMP="$(usex openmp)"
	)
	CMAKE_BUILD_TYPE=Release cmake_src_configure
}

src_test() {
	cd graphs || die
	local PATH="${BUILD_DIR}"/programs/:${PATH}

	ndmetis mdual.graph || die
	mpmetis metis.mesh 2 || die
	gpmetis test.mgraph 4 || die
	gpmetis copter2.graph 4 || die
	graphchk 4elt.graph || die
}

src_install() {
	cmake_src_install
	use doc && dodoc manual/manual.pdf
	if use examples; then
		docinto examples
		dodoc -r programs graphs
	fi

	cat >> "${T}"/metis.pc <<- EOF || die
		prefix=${EPREFIX}/usr
		exec_prefix=\${prefix}
		libdir=\${exec_prefix}/$(get_libdir)
		includedir=\${prefix}/include

		Name: METIS
		Description: Software for partioning unstructured graphes and meshes
		Version: ${PV}
		Cflags: -I\${includedir}
		Libs: -L\${libdir} -lmetis -lGKlib
	EOF
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${T}"/metis.pc
}
