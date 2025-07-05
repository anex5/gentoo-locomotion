# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit linux-info python-r1 toolchain-funcs

DESCRIPTION="Report file access events from all running processes"
HOMEPAGE="https://github.com/martinpitt/fatrace"
SRC_URI="https://github.com/martinpitt/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~mips ~mipsel"
IUSE="man doc powertop"

RDEPEND="powertop? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"
REQUIRED_USE="powertop? ( ${PYTHON_REQUIRED_USE} )"

RESTRICT="mirror"

CONFIG_CHECK="~FANOTIFY"

src_prepare() {
	default
	tc-export CC
}

src_install() {
	dosbin fatrace
	use powertop && dosbin power-usage-report

	use man && doman fatrace.8
	use doc && dodoc NEWS
}
