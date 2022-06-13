# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..10} )

inherit git-r3 python-single-r1 systemd

DESCRIPTION="Klipper is a 3d-Printer firmware"
HOMEPAGE="https://www.klipper3d.org/"
EGIT_REPO_URI="https://github.com/Klipper3d/klipper"
EGIT_BRANCH="master"

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

DOCS=( COPYING )

src_compile() {
	:
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
	local python_scripts=( scripts/buildcommands.py \
		scripts/calibrate_shaper.py \
		scripts/update_chitu.py \
		scripts/update_mks_robin.py \
		klippy/klippy.py \
	)

	insinto "/opt/${PN}"
	doins -r Makefile klippy lib src

	insinto "/opt/${PN}/scripts"
	insopts -m0755
	doins -r ${python_scripts[@]} scripts/flash-*.sh scripts/check-gcc.sh

	# UPSTREAM-ISSUE https://github.com/KevinOConnor/klipper/issues/3689
	for f in ${python_scripts[@]}; do
		sed -i -r -e "s/(\!\/usr\/bin\/env )python2/\1${EPYTHON}/" "${D}/opt/${PN}/${f}" || die
	done

	chmod 0755 "${D}/opt/${PN}/klippy/klippy.py"
	#python_fix_shebang ${python_scripts[@]}

	use systemd && systemd_newunit "${FILESDIR}/klipper.service" "klipper.service"

	dodir /etc/klipper
	keepdir /etc/klipper

	dodir /var/spool/klipper/virtual_sdcard
	keepdir /var/spool/klipper/virtual_sdcard

	dodir /var/log/klipper
	keepdir /var/log/klipper

	fowners -R klipper:klipper /opt/klipper /var/spool/klipper/ /etc/klipper /var/log/klipper

	doenvd "${FILESDIR}/99klipper"
}

pkg_postinst() {
	echo
	elog "Next steps:"
	elog "  create a cross-compiler for your printer board, for example MKS robin E3D board uses following toolchain:"
	elog
	elog "  crossdev -t arm-none-eabi --lenv 'USE=nano' --genv 'EXTRA_ECONF=\"--with-multilib-list=rmprofile\"' --without-headers"
	elog
	elog "  Use following command to configure your printer board firmware:"
	elog
	elog "    cd /opt/klipper"
	elog "    make ARCH=\${ARCH} CROSS_PREFIX=\${ARCH}-none-eabi- menuconfig"
	elog
	elog "  to build the firmware: "
	elog
	elog "    make ARCH=\${ARCH} CROSS_PREFIX=\${ARCH}-none-eabi- -j\$(nproc)"
	elog
	elog "  Use official klipper documentation for flash instructions."
	elog
	elog "  Provide a valid printer.cfg in /etc/klipper, which should be writeable by the user 'klipper'"
	elog "  Afterwards enable the klipper service with:"
	elog
	elog "    systemctl enable klipper.service"
	elog
	elog "  To use the virtual_sdcard feature of klipper the path"
	elog "  /var/spool/klipper/virtual_sdcard/"
	elog "  should be used in printer.cfg."
	echo
}
