# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_{11..14} pypy3_11 )

inherit distutils-r1 pypi systemd

DESCRIPTION="API Web Server for Klipper"
HOMEPAGE="https://github.com/Arksine/moonraker"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Arksine/${PN}"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/Arksine/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~mips"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="systemd doc"

DEPEND="
	acct-group/klipper
	acct-user/klipper
"
RDEPEND="${DEPEND}
	${PYTHON_DEPS}
	app-misc/klipper
	>=dev-python/apprise-1.9.2[${PYTHON_USEDEP}]
	>=dev-python/distro-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/inotify-simple-1.3.5[${PYTHON_USEDEP}]
	>=dev-python/importlib-metadata-4.13.0[${PYTHON_USEDEP}]
	>=dev-python/streaming-form-data-1.11.0[${PYTHON_USEDEP}]
	>=dev-python/dbus-fast-2.28.0[${PYTHON_USEDEP}]
	>=dev-python/paho-mqtt-1.6.1[${PYTHON_USEDEP}]
	>=dev-python/ldap3-2.9.1[${PYTHON_USEDEP}]
	>=dev-python/libnacl-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/jinja2-3.1.5[${PYTHON_USEDEP}]
	>=dev-python/libnacl-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/pillow-9.5.0[${PYTHON_USEDEP}]
	>=dev-python/pyserial-3.4[${PYTHON_USEDEP}]
	>=dev-python/tornado-6.2[${PYTHON_USEDEP}]
	>=dev-python/zeroconf-0.131.0[${PYTHON_USEDEP}]
"

RESTRICT="mirror test"

DOCS=( LICENSE docs/api_changes.md )

src_prepare() {
	sed -i -e 's|^DEFAULT_KLIPPY_LOG_PATH.*|DEFAULT_KLIPPY_LOG_PATH = "/var/log/klipper/klipper.log"|g' moonraker/components/application.py || die

	use systemd || ( eapply "${FILESDIR}/moonraker-openrc.patch" || die )

	distutils-r1_src_prepare
}

src_compile() {
	local -x PDM_BUILD_SCM_VERSION=${PV}
	distutils-r1_src_compile
}

src_install() {
	if use doc; then
		dodoc -r ${DOCS[@]} docs/api_changes.md docs/configuration.md docs/dev_changelog.md docs/plugins.md docs/printer_objects.md docs/user_changes.md docs/web_api.md
	fi

    distutils-r1_src_install

	insinto "/etc/klipper"
	doins "${FILESDIR}/${PN}.conf"
	insinto "/usr/share/polkit-1/rules.d"
	doins "${FILESDIR}/${PN}.rules"

	dodir var/log/${PN}
	keepdir var/log/${PN}
	fperms 0755 "var/log/${PN}"
	fowners klipper:klipper "var/log/${PN}"

	use systemd && systemd_newunit "${FILESDIR}/${PN}.service" "${PN}.service" || newinitd "${FILESDIR}/${PN}.initd" ${PN}
}

pkg_postinst() {
	echo
	elog "Moonraker depends on the following configuration items in the printer.cfg of klipper for full functionality:"
	elog "    [display_status]"
	elog "    [pause_resume]"
	elog "    [virtual_sdcard]"
	echo
	elog "Provide an API Key at /etc/klipper/api_key with owner and group klipper and permissions 0640"
}
