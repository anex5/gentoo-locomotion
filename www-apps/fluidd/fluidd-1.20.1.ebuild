# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

HOMEPAGE="https://docs.fluidd.xyz"
DESCRIPTION="A free and open-source Klipper web interface for managing your 3d printer."
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/fluidd-core/${PN}"
	EGIT_BRANCH="develop"
	KEYWORDS=""
else
	SRC_URI="https://github.com/fluidd-core/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~mips"
fi

KEYWORDS="~amd64 ~arm ~arm64 ~x86 ~mips"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

BDEPEND="
	net-libs/nodejs[npm]
"
DEPEND="
	app-misc/moonraker
	www-servers/nginx
"
RESTRICT="mirror"

S=${WORKDIR}/${P}

src_compile() {
	# Skip, nothing to compile here.
	:
}

src_install() {
	local myopts=(
		--audit false
		--color false
		--foreground-scripts
		--global
		--offline
		--omit dev
		--prefix "${ED}"/usr
		--progress false
		--verbose
	)

	npm ${myopts[@]} install --no-update-notifier --no-audit --cache "npm-cache" || die "npm install failed"
	#npm ${myopts[@]} install "${DISTDIR}"/${P}.tgz || die "npm install failed"
	#./node_modules/.bin/vue-cli-service build || die "vue failed"

	dodir "/usr/share/${PN}"
	insinto "/usr/share/${PN}"
	doins "${S}/favicon.ico" "${S}/index.html" "${S}/manifest.json" "${S}/robots.txt"

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
