# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER=3.2-gtk3
inherit toolchain-funcs wxwidgets desktop

DESCRIPTION="wxWidgets-based EDID (Extended Display Identification Data) editor"
HOMEPAGE="https://wxedid.sourceforge.io"
SRC_URI="https://downloads.sourceforge.net/${PN}/${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~riscv ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="x11-libs/wxGTK:${WX_GTK_VER}"

QA_PRESTRIPPED="usr/bin/wxedid"

S="${WORKDIR}/${PN}-${PV}"

PATCHES=(
	"${FILESDIR}"/${PN}_xdg_cfg.patch
)

pkg_setup() {
	setup-wxwidgets
}

src_install() {
	default
	insinto /usr/share/applications
	domenu "${FILESDIR}/net.sourceforge.wxEDID.desktop"
	doicon -s scalable "${FILESDIR}/net.sourceforge.wxEDID.svg"
}
