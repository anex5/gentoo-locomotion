# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8,9} )

inherit python-single-r1 systemd

DESCRIPTION="API Web Server for Klipper"
HOMEPAGE="https://github.com/Arksine/moonraker"
SRC_URI="https://github.com/Arksine/moonraker/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc"

DEPEND="
	acct-group/klipper
	acct-user/klipper"

RDEPEND="${DEPEND}
	${PYTHON_DEPS}
	app-misc/klipper
	$(python_gen_cond_dep '
		>=dev-python/pillow-8.0.1[${PYTHON_USEDEP}]
		>=dev-python/pyserial-3.4[${PYTHON_USEDEP}]
		>=www-servers/tornado-6.1[${PYTHON_USEDEP}]')"

DOCS=( LICENSE docs/api_changes.md )

src_prepare() {
	sed -i -e 's|^DEFAULT_KLIPPY_LOG_PATH.*|DEFAULT_KLIPPY_LOG_PATH = "/var/log/klipper/klipper.log"|g' moonraker/app.py || die

	default
}

src_install() {
	if use doc; then
		dodoc -r ${DOCS[@]} docs/api_changes.md docs/configuration.md docs/dev_changelog.md docs/plugins.md docs/printer_objects.md docs/user_changes.md docs/web_api.md
	fi

	diropts -o klipper -g klipper
	insopts -o klipper -g klipper
	dodir "/opt/${PN}"
	insinto "/opt/${PN}"
	doins -r moonraker
	dodir "/opt/${PN}/scripts"
	insinto "/opt/${PN}/scripts"
	doins scripts/extract_metadata.py "${FILESDIR}/update_manager.conf"

	python_fix_shebang "${D}/opt/moonraker/moonraker/moonraker.py" || die

	systemd_newunit "${FILESDIR}/moonraker.service" "moonraker.service"
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
