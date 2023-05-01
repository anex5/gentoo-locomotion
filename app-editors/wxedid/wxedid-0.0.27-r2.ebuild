# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER=3.0-gtk3
inherit toolchain-funcs wxwidgets

DESCRIPTION="wxWidgets-based EDID (Extended Display Identification Data) editor"
HOMEPAGE="https://wxedid.sourceforge.io"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~riscv ~x86"
IUSE=""
RESTRICT="mirror"

BDEPEND="
	x11-libs/wxGTK:${WX_GTK_VER}[X]"

QA_PRESTRIPPED="/usr/bin/wxedid"

S="${WORKDIR}/${PN}-${PV}"

PATCHES=(
#	"${FILESDIR}"/${P}-syslibs.patch
#	"${FILESDIR}"/${P}-desktop.patch
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && tc-check-openmp
}

src_prepare() {
	setup-wxwidgets
	default
}
