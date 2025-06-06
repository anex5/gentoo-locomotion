# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ "${PV}" == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/kennylevinsen/wlsunset"
else
	KEYWORDS="~amd64"
	SRC_URI="
		https://github.com/kennylevinsen/wlsunset/archive/${PV}.tar.gz -> ${P}.tar.gz
		https://git.sr.ht/~kennylevinsen/wlsunset/archive/${PV}.tar.gz -> ${P}.tar.gz
	"
fi

DESCRIPTION="Day/night gamma adjustments for Wayland"
HOMEPAGE="https://sr.ht/~kennylevinsen/wlsunset/"
IUSE="man systemd"
LICENSE="MIT"
SLOT="0"
RESTRICT="mirror"

BDEPEND="
	dev-util/wayland-scanner
	man? ( app-text/scdoc )
	virtual/pkgconfig
"
RDEPEND="dev-libs/wayland"
DEPEND="
	${RDEPEND}
	dev-libs/wayland-protocols
"

src_configure() {
	local emesonargs=(
		"-Dwerror=false"
		$(meson_feature man man-pages)
	)

	meson_src_configure
}

src_install() {
	local DOCS=( README.md LICENSE )
	meson_src_install

	if ! use systemd; then
		exeinto /etc/user/init.d
		newexe "${FILESDIR}"/${PN}.user.initd ${PN}
	fi
}
