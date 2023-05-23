# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10,11} )

MY_PN="Ulauncher"

inherit distutils-r1

DESCRIPTION="Application launcher for Linux on wayland"
HOMEPAGE="https://ulauncher.io"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${MY_PN}/${MY_PN}"
	EGIT_SUBMODULES=()
	EGIT_BRANCH="v6"
	KEYWORDS=""
else
	SRC_URI="https://github.com/Ulauncher/Ulauncher/archive/v${PV}/${P}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S=${WORKDIR}/${MY_PN}-${PV}
fi

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"

IUSE="doc test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	net-libs/webkit-gtk:6
"

BDEPEND="
	dev-libs/keybinder
	x11-libs/gtk+:3[wayland]
	>=x11-libs/libnotify-0.8.2
	x11-libs/gdk-pixbuf:2
	>=x11-misc/wmctrl-1.07-r3
	>=dev-python/pydbus-0.6.0
	>=dev-python/Levenshtein-0.21.0
	>=dev-python/pyinotify-0.9.6-r1
	>=dev-python/websocket-client-1.5.1
	>=dev-python/pyxdg-0.28
	dev-python/pygobject:3
	>=dev-python/pycairo-1.23.0
	x11-libs/libwnck:3
"

RESTRICT="
	mirror
	test ( test )
"

