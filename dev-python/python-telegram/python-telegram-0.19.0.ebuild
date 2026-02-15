# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1

inherit distutils-r1

DESCRIPTION="Python client for the Telegram's tdlib"
HOMEPAGE="
	https://github.com/alexander-akhmetov/python-telegram
	https://pypi.org/project/python-telegram
"
SRC_URI="https://github.com/alexander-akhmetov/python-telegram/archive/refs/tags/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
RESTRICT="mirror"
#S="${WORKDIR}/${PV}"

RDEPEND="${PYTHON_DEPS}"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	dev-python/telegram-text[${PYTHON_USEDEP}]
	test? (
		>=dev-python/pytest-7.0.1[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
	)
"
distutils_enable_tests pytest

pkg_setup() {
	export SETUPTOOLS_SCM_PRETEND_VERSION="${PV%_*}"
}

src_install() {
	distutils-r1_src_install
	docinto "licenses"
	dodoc "LICENSE"
}
