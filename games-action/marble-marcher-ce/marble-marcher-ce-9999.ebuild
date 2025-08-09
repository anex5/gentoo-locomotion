# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake readme.gentoo-r1

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/WAUthethird/Marble-Marcher-Community-Edition"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/WAUthethird/Marble-Marcher-Community-Edition/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	S=${WORKDIR}/Marble-Marcher-Community-Edition-${PV}
	KEYWORDS="~amd64 ~x86"
fi

MY_PN="MarbleMarcher"

DESCRIPTION="A procedurally rendered fractal physics marble game"
HOMEPAGE="https://michaelmoroz.itch.io/mmce"

SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND="
	>=media-libs/libsfml-2.5.1
	media-libs/glew:=[X(+)]
	media-libs/glm:=
	media-libs/openal:*
	media-libs/anttweakbar:*
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-libs/boost-1.60.0
	>=dev-cpp/eigen-3.3.4
"

RESTRICT="mirror"

DOC_CONTENTS="
Marble Marcher: Community Edition comes with a wealth of new features and improvements, including performance improvements and graphical enhancements.
"


src_configure() {
	CMAKE_BUILD_TYPE="Release"

	sed -i "/ SFML_STATIC/d" CMakeLists.txt || die

	cmake_src_configure
}

src_install() {
	cmake_src_install

	local MMCE_HOME="/usr/$(get_libdir)/${PN}"

	exeinto "${MMCE_HOME}"
	insinto "${MMCE_HOME}"
	doins "${BUILD_DIR}/src/libMarbleMarcherSources.so"
	echo "#! /bin/sh" > ${MY_PN}-launcher.sh
	echo "pushd \"${MMCE_HOME}\" > /dev/null && LD_LIBRARY_PATH=\"${MMCE_HOME}\" exec \"./\$(basename \$0)\" \"\$\@\" && popd" >> ${MY_PN}-launcher.sh
	doexe "${MY_PN}-launcher.sh"
	dosym "${MMCE_HOME}/${MY_PN}-launcher.sh" /usr/bin/${MY_PN}

	mkdir -p ${D}/usr/share/${PN} || die
	mv ${D}/home/MMCE/* ${D}/${MMCE_HOME} || die
	rm -r ${D}/home || die
	mkdir -p ${D}/usr/share/applications &&	cat >"${D}/usr/share/applications/${MY_PN}.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Marble Marcher: Community Edition
Icon=${MMCE_HOME}/images/MarbleMarcher.png
Exec=/usr/bin/${MY_PN}
Categories=Game;
Terminal=false
EOF

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
