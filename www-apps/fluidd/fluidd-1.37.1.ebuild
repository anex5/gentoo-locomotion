# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A free and open-source Klipper web interface for managing your 3d printer"
HOMEPAGE="https://docs.fluidd.xyz"

SRC_URI="https://github.com/fluidd-core/fluidd/releases/download/v${PV}/${PN}.zip -> ${P}.zip"
S="${WORKDIR}"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="amd64 arm64 arm mips x86"

BDEPEND="
	app-arch/unzip
"
RDEPEND="
	app-misc/moonraker
	www-servers/nginx
"

RESTRICT="mirror"

src_compile() {
	:
}

src_install() {
	dodir /usr/share/${PN}
	cp -R . "${ED}"/usr/share/"${PN}" || die "Copy files failed"

	insinto /etc/klipper
	doins "${FILESDIR}/config.json"
	dosym ../../../etc/klipper/config.json /var/www/${PN}/config.json

	insinto /etc/nginx/conf.d
	doins "${FILESDIR}"/fluidd.conf "${FILESDIR}"/upstreams.conf "${FILESDIR}"/common_vars.conf
}

pkg_postinst() {
	echo
	elog "Adapt /etc/klipper/config.json to your needs"
}
