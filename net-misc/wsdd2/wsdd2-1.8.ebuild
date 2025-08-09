# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs systemd

DESCRIPTION="WSD/LLMNR Discovery/Name Service Daemon"
HOMEPAGE="https://github.com/kochinc/wsdd2"

SRC_URI="https://github.com/kochinc/${PN}/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
IUSE="systemd man"
KEYWORDS="~amd64 ~arm ~x86 ~mips"
RESTRICT="mirror"

S="${WORKDIR}/${PN}-master"

DEPEND=""

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" ${PN}
}

src_install() {
	dosbin ${PN}
	if use "systemd"; then
		systemd_dounit "${PN}.service"
		systemd_enable_service "system-services.target" "${PN}.service"
	fi
	use "man" && doman "${S}/${PN}.8"
}

pkg_postinst() {
	elog "WSD daemon is part of smbd service.\nRun: /usr/sbin/wsdd2"
}
