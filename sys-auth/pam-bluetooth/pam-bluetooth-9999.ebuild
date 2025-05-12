# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit pam git-r3

DESCRIPTION="PAM module to authenticate users via bluetooth device"
HOMEPAGE="https://github.com/Taumille/pam-bluetooth"

EGIT_REPO_URI="https://github.com/Taumille/pam-bluetooth"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~mips"

IUSE="doc"

RDEPEND="
	net-wireless/bluez-tools
	sys-libs/pam
"
DEPEND="${RDEPEND}"

#PATCHES=(
	#"${FILESDIR}"/${PN}-0.7.3.2-Fix-crypt-implicit-function-declaration.patch
#)

_emake() {
	local myemakeargs=(
		"PREFIX=${EPREFIX}/usr"
		"HOST_CC=$(tc-getBUILD_CC)"
		"HOST_CFLAGS=${BUILD_CPPFLAGS} ${BUILD_CFLAGS}"
		"HOST_LDFLAGS=${BUILD_LDFLAGS}"
		"CC=$(tc-getCC)"
		"LD=$(tc-getLD)"
	)

	emake "${myemakeargs[@]}" "${@}"
}

src_configure() {
	default
	sed -e "s/gcc/\$\{CC\} \$\{CFLAGS\}/" \
		-e "s/ld -x --shared -o \/lib64\/security\/pam_bluetooth\.so/\$\{CC\} \$\{LDFLAGS\} -Wl,-x,\$\{XLDFLAGS\} -o pam_bluetooth\.so/" \
		-e "/touch \/etc\/security\/authorized_bluetooth\.conf/d" \
		-i Makefile || die
}

src_compile() {
	_emake default
}

src_install() {
	_emake "DESTDIR=${D}" "XLDFLAGS=-shared" install
	dopammod pam_bluetooth.so
	use doc && dodoc README.md
	echo -e "FF:FF:FF:FF:FF:FF" > "${T}/authorized_bluetooth.conf" || die
	insinto /etc/security/
	doins "${T}/authorized_bluetooth.conf"
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		elog "You must edit ${EROOT}/etc/security/authorized_bluetooth.conf yourself, containing"
		elog "MAC address of your device."
	fi
}
