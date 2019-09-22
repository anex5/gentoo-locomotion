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
KEYWORDS="~amd64 ~arm ~x86 ~mips ~mipsel ~mips64el"

DEPEND="
	dev-vcs/git
"

src_compile() {
	# By default, it builds a bunch of unittests that are missing wrapper
	# scripts in the tarball
	emake CC="$(tc-getCC)" STRIP=true wsdd2
}

src_install() {
	emake -j1 DESTDIR="${ED}" STRIP=true install wsdd2
	dosbin wsdd2
	if use "systemd"; then
		systemd_dounit "wsdd2.service"
		systemd_enable_service "system-services.target" "wsdd2.service"
	fi
	use "doc" && einstalldoc
}

pkg_postinst() {
	elog "WSD daemon is part of smbd service. To start use /usr/sbin/wsdd2"	
}