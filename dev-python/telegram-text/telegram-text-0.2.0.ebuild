# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10..14} pypy3 )

inherit distutils-r1

DESCRIPTION="Python markup module for Telegram messenger"
HOMEPAGE="https://github.com/SKY-ALIN/telegram-text"

SRC_URI="https://github.com/SKY-ALIN/telegram-text/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

DEPEND="
	>=dev-python/alabaster-0.7.13[${PYTHON_USEDEP}]
	>=dev-python/astroid-3.2.2[${PYTHON_USEDEP}]
	>=dev-python/babel-2.14.0[${PYTHON_USEDEP}]
	>=dev-python/pytz-2015.7[${PYTHON_USEDEP}]
	>=dev-python/freezegun-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/charset-normalizer-3.4.2[${PYTHON_USEDEP}]
	>=dev-python/certifi-2023.11.17[${PYTHON_USEDEP}]
	>=dev-python/idna-3.7[${PYTHON_USEDEP}]
	>=dev-python/imagesize-1.4.1[${PYTHON_USEDEP}]
	>=dev-python/importlib-metadata-7.0.1[${PYTHON_USEDEP}]
	>=dev-python/iniconfig-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/isort-5.13.2[${PYTHON_USEDEP}]
	>=dev-python/jinja2-3.1.4[${PYTHON_USEDEP}]
	>=dev-python/libcst-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/markupsafe-2.1.3[${PYTHON_USEDEP}]
	>=dev-python/mccabe-0.7.0[${PYTHON_USEDEP}]
	>=dev-python/mistune-3.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.32.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-23.2[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.1.0[${PYTHON_USEDEP}]
	>=dev-python/soupsieve-2.5[${PYTHON_USEDEP}]
	>=dev-python/snowballstemmer-2.2.0[${PYTHON_USEDEP}]
	>=dev-python/typer-0.9.0[${PYTHON_USEDEP}]
	>=dev-python/tomli-2.0.1[${PYTHON_USEDEP}]
	>=dev-python/tomlkit-0.12.3[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26.6[${PYTHON_USEDEP}]
	>=dev-python/zipp-3.19.1[${PYTHON_USEDEP}]
"

RESTRICT="mirror"

: ${EPYTEST_TIMEOUT:=5}
distutils_enable_tests pytest

