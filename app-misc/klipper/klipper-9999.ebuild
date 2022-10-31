# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..11} )

inherit python-single-r1 systemd

DESCRIPTION="Klipper is a 3d-Printer firmware"
HOMEPAGE="https://www.klipper3d.org/"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Klipper3d/${PN}"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/Klipper3d/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~mips"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc examples systemd"

DEPEND="
	acct-group/klipper
	acct-user/klipper
"
RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
	sys-libs/ncurses:0=
	virtual/libusb:1
	$(python_gen_cond_dep '
		>=dev-python/jinja-2.10.1[${PYTHON_USEDEP}]
		>=dev-python/pyserial-3.4[${PYTHON_USEDEP}]
		dev-python/virtualenv[${PYTHON_USEDEP}]
		virtual/python-cffi[${PYTHON_USEDEP}]
		virtual/python-greenlet[${PYTHON_USEDEP}]
	')
"
RESTRICT="mirror"

DOCS=( COPYING )

# set_config <file> <option name> <yes value> <no value> test
# a value of "#" will just comment out the option
set_config() {
	local file="${ED}/$1" var=$2 val com
	eval "${@:5}" && val=$3 || val=$4
	[[ ${val} == "#" ]] && com="#" && val='\2'
	sed -i -r -e "/^#?${var}=/{s:=([\"'])?([^ ]*)\1?:=\1${val}\1:;s:^#?:${com}:}" "${file}"
}

set_config_yes_no() {
	set_config "$1" "$2" YES NO "${@:3}"
}

src_compile() {
	sed -i -r -e "s/(\!\/usr\/bin\/env )python2/\1${EPYTHON}/" klippy/klippy.py || die
	${EPYTHON} -m compileall klippy
	${EPYTHON} klippy/chelper/__init__.py
}

src_install() {
	if use doc; then
		dodoc -r ${DOCS[@]} docs/*.md docs/img docs/prints
	fi

	if use examples; then
		insinto "/usr/share/${PN}/examples"
		doins -r config/*
	fi

	insinto "/opt/${PN}"
	doins -r Makefile klippy lib src

	# currently only these are python3 compatible or have missing dependencies
	local python_scripts=( \
		buildcommands.py \
		calibrate_shaper.py \
		update_chitu.py \
		update_mks_robin.py \
	)

	# UPSTREAM-ISSUE https://github.com/KevinOConnor/klipper/issues/3689
	for f in ${python_scripts[@]}; do
		sed -i -r -e "s/(\!\/usr\/bin\/env )python2/\1${EPYTHON}/" "scripts/${f}" || die
	done

	insinto "/opt/${PN}/scripts"
	insopts -m0755
	pushd scripts >/dev/null || die
	python_fix_shebang ${python_scripts[@]}
	doins -r ${python_scripts[@]} flash-*.sh check-gcc.sh
	popd >/dev/null || die

	chmod 0755 "${D}/opt/${PN}/klippy/klippy.py"

	use systemd && systemd_newunit "${FILESDIR}/${PN}.service" "${PN}.service" || newinitd "${FILESDIR}/${PN}.initd" ${PN}

	dodir /etc/${PN}
	keepdir /etc/${PN}

	dodir /var/spool/${PN}/virtual_sdcard
	keepdir /var/spool/${PN}/virtual_sdcard

	dodir /var/log/${PN}
	keepdir /var/log/${PN}

	fowners -R ${PN}:${PN} /opt/${PN} /var/spool/${PN}/ /etc/${PN} /var/log/${PN}

	use systemd || set_config /etc/rc.conf rc_env_allow "KLIPPER_CONFIG KLIPPER_LOG KLIPPER_SOCKET"

	doenvd "${FILESDIR}/99klipper"
}

pkg_postinst() {
	echo
	elog "Next steps:"
	elog "  create a cross-compiler for your printer board, for example MKS robin E3D board uses following toolchain:"
	elog "    crossdev -t arm-none-eabi --lenv 'USE=nano' --genv 'EXTRA_ECONF=\"--with-multilib-list=rmprofile\"' --without-headers"
	elog
	elog "  Use following command to configure your printer board firmware:"
	elog "    cd /opt/klipper"
	elog "    make ARCH=\${ARCH} CROSS_PREFIX=\${ARCH}-none-eabi- menuconfig"
	elog
	elog "  to build the firmware: "
	elog "    make ARCH=\${ARCH} CROSS_PREFIX=\${ARCH}-none-eabi- -j\$(nproc)"
	elog
	elog "  Use official klipper documentation for flash instructions."
	elog
	elog "  Provide a valid printer.cfg in /etc/klipper, which should be writeable by the user 'klipper'"
	elog
	elog "  Afterwards run the klipper service with:"
	elog "    /etc/init.d/klipper start"
	elog "  or with systemd service"
	elog "    systemctl enable klipper.service"
	elog
	elog "  To use the virtual_sdcard feature of klipper the path"
	elog "  /var/spool/klipper/virtual_sdcard/ should be used in printer.cfg."
	echo
}
