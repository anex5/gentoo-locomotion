# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

DISTUTILS_USE_PEP517=setuptools
#DISTUTILS_EXT=1

inherit distutils-r1

DESCRIPTION="A patched mailcap module that conforms to RFC 1524"
HOMEPAGE="
	https://github.com/michael-lazar/mailcap_fix
	https://pypi.org/project/mailcap_fix
"
SRC_URI="https://github.com/michael-lazar/mailcap_fix/archive/refs/tags/v${PV}/${P}.tar.gz"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
RESTRICT="mirror"
#S="${WORKDIR}/${PV}"

RDEPEND="${PYTHON_DEPS}"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		>=dev-python/pytest-7.0.1[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
	)
"
distutils_enable_tests pytest

