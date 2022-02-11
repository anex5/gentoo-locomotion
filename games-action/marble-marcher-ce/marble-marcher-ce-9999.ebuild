# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 cmake readme.gentoo-r1

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/WAUthethird/Marble-Marcher-Community-Edition"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/WAUthethird/Marble-Marcher-Community-Edition/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="A procedurally rendered fractal physics marble game"
HOMEPAGE="https://michaelmoroz.itch.io/mmce"

SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND="
	>=media-libs/libsfml-2.5.0
	media-libs/glew:=
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
	cmake_src_configure
}

src_install() {
	cmake_src_install

	local MMCE_HOME="/usr/$(get_libdir)/${PN}"

	exeinto "${MMCE_HOME}"
	insinto "${MMCE_HOME}"
	doins "${BUILD_DIR}/src/libMarbleMarcherSources.so"
	echo "#! /bin/sh" > MarbleMarcher-launcher.sh
	echo "pushd \"${MMCE_HOME}\" > /dev/null && LD_LIBRARY_PATH=\"${MMCE_HOME}\" exec \"./\$(basename \$0)\" \"\$\@\" && popd" >> MarbleMarcher-launcher.sh
	doexe "MarbleMarcher-launcher.sh"
	dosym "${MMCE_HOME}/MarbleMarcher-launcher.sh" /usr/bin/MarbleMarcher

	mkdir -p ${D}/usr/share/${PN} || die
	mv ${D}/home/MMCE/* ${D}/${MMCE_HOME} || die
	rm -r ${D}/home || die

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
