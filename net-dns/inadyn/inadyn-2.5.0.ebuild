# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils systemd

DESCRIPTION="Dynamic DNS client with SSL/TLS support"
HOMEPAGE="http://troglobit.com/projects/inadyn"
PV_2=$(ver_cut 1-2)

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/troglobit/${PN}"
	#EGIT_COMMIT="9d3d7852991d04438079f61e8f6092cd7b86668a"
else
	SRC_URI="https://github.com/troglobit/${PN}/releases/download/v${PV_2}/${PN}-${PV_2}.tar.xz"
fi

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86 ~mips"
IUSE="systemd man"

DEPEND="
	app-arch/xz
	dev-libs/confuse
"
RDEPEND=""

S="${WORKDIR}/${PN}-${PV_2}"

src_compile() {
	cd src || die
	emake || die
}

src_install() {
	dosbin src/inadyn || die
	usex "man" && doman "man/${PN}.8" "man/${PN}.conf.5" || die

	newinitd "${FILESDIR}"/inadyn.initd inadyn || die
	if use "systemd"; then
		systemd_dounit "${PN}.service"
		systemd_enable_service "system-services.target" "${PN}.service"
	fi

	insinto /etc
	doins ${S}/examples/inadyn.conf || die
}

pkg_postinst() {
	elog "You will need to edit /etc/inadyn.conf file before"
	elog "running inadyn for the first time. The file is basically"
	elog "command line options; see inadyn and inadyn.conf manpages."
}
