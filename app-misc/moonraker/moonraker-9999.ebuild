# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..11} )

inherit python-single-r1 systemd

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
	dev-libs/libgpiod
	$(python_gen_cond_dep '
		dev-python/distro[${PYTHON_USEDEP}]
		dev-python/inotify-simple[${PYTHON_USEDEP}]
		dev-python/streaming-form-data[${PYTHON_USEDEP}]
		dev-python/dbus-next[${PYTHON_USEDEP}]
		dev-python/paho-mqtt[${PYTHON_USEDEP}]
		dev-python/lmdb[${PYTHON_USEDEP}]
		dev-python/libnacl[${PYTHON_USEDEP}]
		dev-python/jinja[${PYTHON_USEDEP}]
		dev-python/libnacl[${PYTHON_USEDEP}]
		>=dev-python/pillow-8.0.1[${PYTHON_USEDEP}]
		>=dev-python/pyserial-3.4[${PYTHON_USEDEP}]
		>=dev-python/tornado-6.1[${PYTHON_USEDEP}]')"

RESTRICT="mirror"

DOCS=( LICENSE docs/api_changes.md )

src_prepare() {
	sed -i -e 's|^DEFAULT_KLIPPY_LOG_PATH.*|DEFAULT_KLIPPY_LOG_PATH = "/var/log/klipper/klipper.log"|g' moonraker/app.py || die

	#use systemd || eapply "${FILESDIR}/moonraker-openrc.patch"

	default
}

src_compile() {
	${EPYTHON} -m compileall -o 0 -o 1 moonraker
}

src_install() {
	if use doc; then
		dodoc -r ${DOCS[@]} docs/api_changes.md docs/configuration.md docs/dev_changelog.md docs/plugins.md docs/printer_objects.md docs/user_changes.md docs/web_api.md
	fi

	diropts -o klipper -g klipper
	insopts -o klipper -g klipper
	insinto "/opt"
	doins -r ${PN}
	insinto "/etc/klipper"
	doins "${FILESDIR}/${PN}.conf"
	insinto "/usr/share/polkit-1/rules.d"
	doins "${FILESDIR}/${PN}.rules"
	dodir "/opt/${PN}/scripts"
	insinto "/opt/${PN}/scripts"

	dodir /var/log/${PN}
	keepdir /var/log/${PN}

	python_fix_shebang "${D}/opt/${PN}/moonraker.py" || die

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
