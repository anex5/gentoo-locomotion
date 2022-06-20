# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )

inherit distutils-r1

MY_PN="${PN/-/_}"
DESCRIPTION="Simple Python wrapper around inotify with ctypes"
HOMEPAGE="https://github.com/chrisjbillington/${MY_PN}"
SRC_URI="https://github.com/chrisjbillington/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~x86 ~arm"

RDEPEND="${PYTHON_DEPS}
"

RESTRICT="test mirror"

S=${WORKDIR}/${MY_PN}-${PV}
