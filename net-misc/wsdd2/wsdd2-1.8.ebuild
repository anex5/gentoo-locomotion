# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3 toolchain-funcs systemd

DESCRIPTION="WSD/LLMNR Discovery/Name Service Daemon"
HOMEPAGE="https://github.com/kochinc/wsdd2"

EGIT_REPO_URI="https://github.com/kochinc/wsdd2"
EGIT_COMMIT="9b1911358e1929632b15e4fe8527fddc42dc139d"

LICENSE="GPL-3"
SLOT="0"
IUSE="systemd doc"
KEYWORDS="~amd64 ~arm ~x86 ~mips"

DEPEND=""

src_compile() {
	emake CC="$(tc-getCC)" wsdd2
}

src_install() {
	dosbin wsdd2
	if use "systemd"; then
		systemd_dounit "wsdd2.service"
		systemd_enable_service "system-services.target" "wsdd2.service"
	fi
	use "doc" && einstalldoc
}

pkg_postinst() {
	elog "WSD daemon is part of smbd service.\nRun: /usr/sbin/wsdd2"
}