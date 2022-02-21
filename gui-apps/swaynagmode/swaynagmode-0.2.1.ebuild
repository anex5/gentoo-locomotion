# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Control swaynag via keyboard shortcuts"
HOMEPAGE="https://github.com/b0o/swaynagmode"
SRC_URI="https://github.com/b0o/${PN}/archive/v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="
	gui-wm/sway
	app-shells/bash
"
RDEPEND="${DEPEND}"
BDEPEND=""

RESTRICT="mirror"

src_compile() {
	:
}

src_install() {
	dobin ${PN}
	default
}
