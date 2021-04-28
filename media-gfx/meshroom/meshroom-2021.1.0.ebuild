# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3_{7..9} )

inherit distutils-r1

DESCRIPTION="3D Reconstruction Software AliceVision Photogrammetric Computer Vision framework"
HOMEPAGE="http://alicevision.github.io"

SRC_URI="https://github.com/alicevision/meshroom/archive/v$PV.tar.gz -> $P.tar.gz
		https://gitlab.com/alicevision/trainedVocabularyTreeData/-/raw/master/vlfeat_K80L3.SIFT.tree
"

IUSE="alembic qtoiio qtalicevision"

LICENSE=MPL-2.0
SLOT=0
KEYWORDS=~amd64
RESTRICT="test mirror"

RDEPEND=">=dev-python/psutil-5.6.3[${PYTHON_USEDEP}]
	>=dev-python/pyside2-5.13.0[qml,quick,${PYTHON_USEDEP}]
	>=dev-python/markdown-2.6.11[${PYTHON_USEDEP}]
	>=dev-python/requests-2.22.0[${PYTHON_USEDEP}]
	>=media-libs/alicevision-2.4.0[alembic?]
	dev-python/enum34
	qtoiio? ( =dev-qt/qtoiio-${PV} )
	qtalicevision? ( =dev-qt/qtalicevision-${PV} )
	dev-python/cx_Freeze[${PYTHON_USEDEP}]"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

src_prepare() {
	# Change the lib install path
	#sed -i "s|/usr/lib|${EPREFIX}/usr/${get_libdir}|g" setup.py || die

	default
}

#src_configure() {
	# Ensure that 'python3' is in PATH. #765118
#	python_setup

#	CMAKE_BUILD_TYPE=Release

#	mycmakeargs=(
#		-DQT_DIR=${EPREFIX}/usr/$(get_libdir)/qt5
		#-DALICEVISION_ROOT=
#		-DMR_BUILD_QTOIIO=$(usex qtoiio)
#		-DMR_BUILD_QMLALEMBIC=NO #$(usex alembic)
#		-DMR_BUILD_QTALICEVISION=$(usex qtalicevision)
#	)
#	cmake_src_configure
#}

