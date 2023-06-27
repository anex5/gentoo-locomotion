# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

HOMEPAGE="https://docs.fluidd.xyz"
DESCRIPTION="A free and open-source Klipper web interface for managing your 3d printer."
inherit git-r3
EGIT_REPO_URI="https://github.com/fluidd-core/${PN}"
EGIT_BRANCH="develop"
KEYWORDS=""

LICENSE="GPL-3"
SLOT="0"
IUSE=""

BDEPEND="
	net-libs/nodejs[npm]
"
RDEPEND="
	app-misc/moonraker
	www-servers/nginx
"
RESTRICT="mirror"

S=${WORKDIR}/${P}

NPM_FLAGS=(
	--audit false
	--color false
	--foreground-scripts
	--progress false
	--save false
	--verbose
	--cache "${T}/npm-cache"
	--target_arch="${ARCH}"
	--target_libc="${ELIBC}"
	--target_platform="${KERNEL}"
	--no-update-notifier
)

src_prepare() {
	default
	npm "${NPM_FLAGS[@]}" install vite || die "npm install failed"
}

src_compile() {
	PATH="${PATH}:$S/node_modules/.bin" NODE_ENV=production vite build || die "vite build failed"
}

src_install() {
	dodir /usr/share/${PN}
	cp -R dist/* "${ED}"/usr/share/"${PN}" || die "Copy files failed"

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
