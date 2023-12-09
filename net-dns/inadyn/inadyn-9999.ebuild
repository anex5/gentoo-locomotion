# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="Dynamic DNS client with SSL/TLS support"
HOMEPAGE="http://troglobit.com/projects/inadyn"

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/troglobit/${PN}"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/troglobit/${PN}/releases/download/v${PV}/${P}.tar.xz"
fi

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86 ~mips"
IUSE="systemd man"

BDEPEND="
	app-arch/xz
	dev-libs/confuse
"
DEPEND="${BDEPEND}"

RESTRICT="mirror"

src_prepare() {
	default
	eautoreconf
}

src_compile() {
	[[ ${PV} != "9999" ]] && cd src
	emake || die
}

src_install() {
	dosbin src/${PN}
	use man && doman "man/${PN}.8" "man/${PN}.conf.5"

	newinitd "${FILESDIR}"/${PN}.initd inadyn
	if use "systemd"; then
		systemd_dounit "${PN}.service"
		systemd_enable_service "system-services.target" "${PN}.service"
	fi

	insinto /etc
	doins ${S}/examples/inadyn.conf
}

pkg_postinst() {
	elog "You will need to edit /etc/inadyn.conf file before"
	elog "running inadyn for the first time. The file is basically"
	elog "command line options; see inadyn and inadyn.conf manpages."
}
