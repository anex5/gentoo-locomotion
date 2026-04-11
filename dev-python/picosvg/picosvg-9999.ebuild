# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1
if [[ -z ${PV%%*9999} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/googlefonts/${PN}.git"
else
	COMMIT="cb1231752a135870ff9c21fc61dc3bfc336e1c00"
	SRC_URI="https://github.com/googlefonts/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	RESTRICT="mirror"
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
	S="${WORKDIR}/${PN}-${COMMIT}"
fi

DESCRIPTION="A tool to simplify SVGs"
HOMEPAGE="https://github.com/googlefonts/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="
	dev-python/absl-py[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/skia-pathops[${PYTHON_USEDEP}]
"
RDEPEND="
	${DEPEND}
"
distutils_enable_tests pytest

pkg_setup() {
	[[ -n ${PV%%*9999} ]] && export SETUPTOOLS_SCM_PRETEND_VERSION="${PV%_*}"
}
