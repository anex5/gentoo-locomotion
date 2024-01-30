# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )

inherit python-single-r1 systemd

DESCRIPTION="Klipper is a 3d-Printer firmware"
HOMEPAGE="https://www.klipper3d.org/"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Klipper3d/${PN}"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/Klipper3d/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	dict? ( https://github.com/Klipper3d/klipper/files/7491378/klipper-dict-20211106.tar.gz )"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="dict doc +examples firmware systemd"

DEPEND="
	acct-group/klipper
	acct-user/klipper
"
RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
	virtual/libusb:1
	firmware? (
		sys-libs/ncurses:0=
		cross-arm-none-eabi/binutils
		cross-arm-none-eabi/gcc
		cross-arm-none-eabi/newlib
	)
	$(python_gen_cond_dep '
		dev-python/numpy
		>=dev-python/jinja-2.10.1[${PYTHON_USEDEP}]
		>=dev-python/pyserial-3.4[${PYTHON_USEDEP}]
		>=dev-python/markupsafe-1.1.1[${PYTHON_USEDEP}]
		dev-python/virtualenv[${PYTHON_USEDEP}]
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

pkg_pretend() {
	if use firmware; then
		if ! has_version -b cross-arm-none-eabi/newlib; then
			ewarn
			ewarn "  create a cross-compiler to build a firmware for your printer board, for example:"
			ewarn "    crossdev -t arm-none-eabi --lenv 'USE=nano' --without-headers"
			ewarn
			die
		fi
	fi
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

	# currently only these are python3 compatible or have missing dependencies
	local python_scripts=( \
		buildcommands.py \
		canbus_query.py \
		checkstack.py \
		dump_mcu.py \
		graph_accelerometer.py \
		flash_usb.py \
		check_whitespace.py \
		calibrate_shaper.py	\
		graph_temp_sensor.py \
		logextract.py \
		make_version.py \
		stepstats.py \
		update_chitu.py \
		update_mks_robin.py \
		whconsole.py \
	)

	# UPSTREAM-ISSUE https://github.com/KevinOConnor/klipper/issues/3689
	for f in ${python_scripts[@]}; do
		sed -i -r -e "s/(\!\/usr\/bin\/env )python.*$/\1${EPYTHON}/" "scripts/${f}" || die
	done
	sed -i -e '1i #!/usr/bin/env python' scripts/test_klippy.py || die
	python_fix_shebang scripts/*.py

	insinto "/usr/$(get_libdir)/${PN}"
	insopts -m0755
	doins -r klippy lib scripts
	if use firmware; then
		doins -r src Makefile
	fi
	dodir /usr/libexec/${PN}
	dosym "/usr/$(get_libdir)/${PN}/klippy" "/usr/libexec/${PN}/klippy"
	#${EPYTHON} scripts/make_version.py GENTOOLINUX > "/usr/$(get_libdir)/${PN}/klippy/.version"

	if use systemd; then
		systemd_newunit "${FILESDIR}/${PN}.service" "${PN}.service"
	else
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	fi

	dodir /etc/${PN}
	keepdir /etc/${PN}

	dodir /var/spool/${PN}/virtual_sdcard
	keepdir /var/spool/${PN}/virtual_sdcard

	fperms 0755 /var/spool/${PN}/virtual_sdcard
	fowners -R ${PN}:${PN} /usr/$(get_libdir)/${PN} /var/spool/${PN} /etc/${PN}

	use systemd || set_config /etc/rc.conf rc_env_allow "KLIPPER_CONFIG KLIPPER_LOG KLIPPER_SOCKET"

	doenvd "${FILESDIR}/99klipper"
}

pkg_postinst() {
	if use firmware; then
		elog
		elog "  Use following command to configure your printer board firmware:"
		elog "    cd /usr/$(get_libdir)/klipper"
		elog "    make ARCH=\${ARCH} CROSS_PREFIX=\${ARCH}-none-eabi- menuconfig"
		elog
		elog "  to build the firmware: "
		elog "    make ARCH=\${ARCH} CROSS_PREFIX=\${ARCH}-none-eabi- -j\$(nproc)"
		elog
		elog "  Use official klipper documentation for flash instructions."
	fi

	elog
	elog "  Provide a valid printer.cfg in /etc/klipper, which should be writeable by the user 'klipper'"
	elog
	elog "  Run the klipper service with:"
	elog "    rc-service klipper start"
	elog "  or with systemd service"
	elog "    systemctl enable klipper.service"
	elog
	elog "  To use the virtual_sdcard feature of klipper the path"
	elog "  /var/spool/klipper/virtual_sdcard/ should be used in printer.cfg."
	elog
}
