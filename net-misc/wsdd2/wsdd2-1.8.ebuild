# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs systemd

DESCRIPTION="WSD/LLMNR Discovery/Name Service Daemon"
HOMEPAGE="https://github.com/kochinc/wsdd2"

SRC_URI="https://github.com/kochinc/${PN}/archive/refs/heads/master.tar.gz -> ${P}.gh.tar.gz"

S="${WORKDIR}/${PN}-master"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~x86"
IUSE="systemd man"
RESTRICT="mirror"

src_prepare() {
	default
	if use !elibc_glibc; then
		sed -e "/\#include \"wsdd\.h\"/ a\#include <libgen\.h>" -i wsdd2.c || die
		sed -e "s/struct msghdr msg \= { \&sa, sizeof sa, \&iov, 1, NULL/struct msghdr msg \= \{ \&sa, sizeof sa, \&iov, 1, 0/" -i wsdd2.c || die
	fi
}

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
