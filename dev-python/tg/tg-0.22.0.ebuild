# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10..14} pypy3 )

inherit distutils-r1

DESCRIPTION="Python client for Telegram"
HOMEPAGE="https://github.com/paul-nameless/tg"

SRC_URI="https://github.com/paul-nameless/tg/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

DEPEND="
	dev-python/python-telegram[${PYTHON_USEDEP}]
	dev-python/mailcap_fix[${PYTHON_USEDEP}]
	dev-python/mypy[${PYTHON_USEDEP}]
	dev-python/tomli[${PYTHON_USEDEP}]
	>=dev-util/ruff-0.11.5
"

RESTRICT="mirror"

: ${EPYTEST_TIMEOUT:=5}
distutils_enable_tests pytest

