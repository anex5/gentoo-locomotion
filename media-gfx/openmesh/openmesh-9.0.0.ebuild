# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_PN="OpenMesh"
MY_PV=$(ver_cut 1-2)
S="${WORKDIR}/${MY_PN}-${PV}"

DESCRIPTION="A generic data structure to represent and manipulate polygonal meshes"
HOMEPAGE="https://www.openmesh.org/"
SRC_URI="https://openmesh.org/media/Releases/${MY_PV/-RC/RC}/${MY_PN}-${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="doc qt5 static-libs test"
RESTRICT="!test? ( test ) mirror"

RDEPEND="
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtwidgets:5
		media-libs/freeglut
	)
	doc? (
		app-doc/doxygen
		media-gfx/graphviz
	)
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
"

#CMAKE_BUILD_TYPE=Release

src_prepare() {
	cmake_src_prepare

	# Fix libdir and remove rpath.
	sed -i -e "s|libdata\/|$(get_libdir)\/|" CMakeLists.txt

	sed -i \
		-e "s|\(set (VCI_PROJECT_LIBDIR \"\).*|\1$(get_libdir)/\")|" \
		-e "s|\(BUILD_WITH_INSTALL_RPATH \)1|\1 0|" \
		-e "s|\(SKIP_BUILD_RPATH\) 0|\1 1|" \
		-e '/^ *INSTALL_RPATH/d' \
		cmake-library/VCI/VCICommon.cmake || die

	if ! use static-libs; then
		sed -i "s|\(SHARED\)ANDSTATIC|\1|" \
			src/${MY_PN}/{Core,Tools}/CMakeLists.txt || die
		sed -i '/OpenMeshCoreStatic/d' \
			src/${MY_PN}/Tools/CMakeLists.txt || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_APPS=$(usex qt5)
		-DOPENMESH_BUILD_UNIT_TESTS=$(usex test)
		-DOPENMESH_DOCS=$(usex doc)
	)

	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}" || die
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${BUILD_DIR}/Build/$(get_libdir) ctest --verbose
}
