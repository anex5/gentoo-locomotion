# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
inherit flag-o-matic pam python-single-r1 toolchain-funcs

DESCRIPTION="Hardware authentication for Linux using ordinary flash media (USB & Card based)."
HOMEPAGE="https://github.com/mcdope/pam_usb"


if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/mcdope/pam_usb"
	inherit git-r3
else
	SRC_URI="https://github.com/mcdope/pam_usb/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~x64-solaris"
	RESTRICT="mirror"
fi

LICENSE="GPL-2"
SLOT="0"

IUSE="doc man systemd"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
	${PYTHON_DEPS}
"
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	dev-libs/libxml2:=
	sys-fs/udisks:2
	sys-libs/pam
"
DEPEND="${RDEPEND}"

_emake() {
	strip-unsupported-flags
	tc-export AR CC

	arch=

	# Override arch detection
	if use x86 ; then
		arch="x86"
	elif use arm ; then
		arch="arm"
	elif use arm64 ; then
		arch="aarch64"
	elif use ppc64 ; then
		arch="ppc64"
	else
		arch="$(uname -m)"
	fi

	local myemakeargs=(
		"PREFIX=${EPREFIX}/usr"
		"LIBDIR=${EPREFIX}/usr/$(get_libdir)"
		"ARCH=${arch}"
		"VERSION=${PV}"
		"CC=$(tc-getCC)"
		"LD=$(tc-getLD)"
	)
	emake "${myemakeargs[@]}" "${@}"
}

src_configure() {
	default
	sed -e "s/gcc/${CC}/" \
		-e "s/all: manpages/all: /" \
		-i Makefile || die
}

src_compile() {
	_emake all
	use man && _emake manpages
}

src_install() {
	dopammod pam_usb.so
	into /usr
	dobin tools/pamusb-conf
	dobin tools/pamusb-agent
	dobin tools/pamusb-keyring-unlock-gnome
	use man && doman doc/*.1
	use doc && dodoc doc/CONFIGURATION doc/QUICKSTART doc/SECURITY doc/TROUBLESHOOTING
	insinto /etc/security
    doins doc/pam_usb.conf
	use systemd && systemd_dounit ${FILESDIR}/pam_usb-agent.service
}

