# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake toolchain-funcs

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/alicevision/AliceVision"
	EGIT_SUBMODULES=( src/dependencies/osi_clp src/dependencies/nanoflann src/dependencies/MeshSDFilter )
	EGIT_BRANCH="master"
	#EGIT_OVERRIDE_COMMIT="6ac5c4e96eb47e6733be28aa2d8b23cc2f4b019b"
    KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
	NANOFLANN_GIT_COMMIT=cc77e17934441dc82b33fd00e0a8a1398f24c928
	OSI_CLP_GIT_COMMIT=38ab28d1c5a53de13c8684cdc272b1deb8cef459
	MESHSDFILTER_GIT_COMMIT=b7dfeed64be90f2eff49345cf65451b700d3a417

	SRC_URI="https://github.com/alicevision/AliceVision/archive/v$PV.tar.gz -> $P.tar.gz
		https://github.com/alicevision/nanoflann/archive/$NANOFLANN_GIT_COMMIT.tar.gz -> nanoflann-$NANOFLANN_GIT_COMMIT.tar.gz
		https://github.com/alicevision/osi_clp/archive/$OSI_CLP_GIT_COMMIT.tar.gz -> osi_clp-$OSI_CLP_GIT_COMMIT.tar.gz
		https://github.com/alicevision/MeshSDFilter/archive/$MESHSDFILTER_GIT_COMMIT.tar.gz -> meshsdfilter-$MESHSDFILTER_GIT_COMMIT.tar.gz"
fi

DESCRIPTION="Photogrammetric framework which provides a 3D Reconstruction and Camera Tracking"
HOMEPAGE="http://alicevision.github.io"

SLOT="0"
LICENSE="MPL-2.0"
IUSE="alembic cuda cctag doc popsift geogram magma mosek opencv opengv openmp test examples ute"

DEPEND="
	>=dev-libs/boost-1.60.0
	>=dev-cpp/eigen-3.3.4
	sci-libs/flann
	sci-libs/lemon[coin]
	magma? ( sci-libs/magma )
	media-libs/openexr:0
	sci-libs/ceres-solver[sparse,lapack]
	sys-libs/zlib
	x11-libs/libXxf86vm
	media-libs/libpng
	media-libs/libjpeg-turbo:=
	>=x11-libs/libXi-1.6.0:=
	x11-libs/libXrandr:=
	media-libs/freetype:=
	media-libs/glu:=
	media-libs/glfw:=
	media-gfx/openmesh:=
	cuda? ( dev-util/nvidia-cuda-toolkit )
	media-libs/openimageio
	opengv? ( media-libs/opengv )
	alembic? ( media-gfx/alembic )
	opencv? ( media-libs/opencv[contribxfeatures2d] )
	geogram? ( >=sci-libs/geogram-1.5.4 )
	mosek? ( =sci-libs/mosek-bin-5.0.0 )
	ute? ( sci-libs/ute-lib )
	doc? (
		>=app-doc/doxygen-1.7.0
		dev-python/sphinx
	)
"

PATCHES=(
	"${FILESDIR}/submodule.patch"
	"${FILESDIR}/cmake-fix-linking.patch"
)

RDEPEND=""
RESTRICT="mirror"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
        git-r3_src_unpack
	else
		S="${WORKDIR}/AliceVision-${PV/_*}"
		unpack ${P}.tar.gz
		cd ${S}
		unpack nanoflann-${NANOFLANN_GIT_COMMIT}.tar.gz
		rmdir src/dependencies/nanoflann
		mv nanoflann-${NANOFLANN_GIT_COMMIT} src/dependencies/nanoflann
		unpack osi_clp-${OSI_CLP_GIT_COMMIT}.tar.gz
		rmdir src/dependencies/osi_clp
		mv osi_clp-${OSI_CLP_GIT_COMMIT} src/dependencies/osi_clp
		unpack meshsdfilter-${MESHSDFILTER_GIT_COMMIT}.tar.gz
		rmdir src/dependencies/MeshSDFilter
		mv MeshSDFilter-${MESHSDFILTER_GIT_COMMIT} src/dependencies/MeshSDFilter
	fi
}

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {
	cmake_src_prepare
	# set std=c++14
	sed -i -e "s|\(set(CMAKE_CXX_STANDARD \)11|\114|" src/CMakeLists.txt || die
	# drop Werror
	sed -i -e 's|-Werror||' src/CMakeLists.txt || die
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DALICEVISION_BUILD_DEPENDENCIES=OFF
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DALICEVISION_USE_INTERNAL_FLANN=ON # Todo unbundle
		-DCERES_INCLUDE_DIRS="/usr/include/ceres"
		-DFLANN_INCLUDE_DIR_HINTS="/usr/include/flann"
		-DCOINUTILS_INCLUDE_DIR_HINTS="/usr/include/coin"
		-DLEMON_INCLUDE_DIR_HINTS="/usr/include/lemon"
		-DCLP_INCLUDE_DIR_HINTS="/usr/include/coin"
		-DOSI_INCLUDE_DIR_HINTS="/usr/include/coin"
		-DMOSEK_LIB=$(usex mosek ON OFF)
		-DMOSEK_SEARCH_HEADER="/opt/mosek/usr/include"
		-DMOSEK_SEARCH_LIB="/opt/mosek/usr/lib"
		-DALICEVISION_USE_OPENMP=$(usex openmp ON OFF)
		-DALICEVISION_USE_CCTAG=$(usex cctag ON OFF)
		-DCCTag_DIR:PATH="/usr/lib/cmake/CCTag"
		-DALICEVISION_USE_OPENGV=$(usex opengv ON OFF)
		-DALICEVISION_USE_ALEMBIC=$(usex alembic ON OFF)
		-DALICEVISION_USE_CUDA=$(usex cuda ON OFF)
		-DCUDA_INCLUDE_DIRS:PATH="/opt/cuda/include"
		-DCUDA_NVCC_EXECUTABLE="/opt/cuda/bin/nvcc"
		-DALICEVISION_USE_POPSIFT=$(usex popsift ON OFF)
		#-DPopSift_DIR:PATH="/usr/lib/cmake/PopSift"
		-DALICEVISION_USE_UNCERTAINTYTE=$(usex ute ON OFF)
		#-DUNCERTAINTYTE_DIR:PATH="/path/to/uncertaintyTE/install/""
		#-DMAGMA_ROOT:PATH="/path/to/magma/install/"
		-DALICEVISION_USE_OPENCV=$(usex opencv ON OFF)
		#-DOPENCV_DIR:PATH="/usr/share/opencv4/"
		-DALICEVISION_REQUIRE_CERES_WITH_SUITESPARSE=ON
		#-DALICEVISION_BUILD_SHARED=ON
		-DALICEVISION_BUILD_TESTS=$(usex test ON OFF)
		-DALICEVISION_BUILD_DOC=$(usex doc ON OFF)
		-DALICEVISION_BUILD_EXAMPLES=$(usex examples ON OFF)
		-DALICEVISION_BUILD_COVERAGE=OFF #$(tc-is-gcc && echo ON || echo OFF)
	)
	cmake_src_configure
}

