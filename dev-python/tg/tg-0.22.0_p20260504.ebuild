# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{13..15} pypy3 )

inherit distutils-r1

DESCRIPTION="Python client for Telegram"
HOMEPAGE="https://github.com/paul-nameless/tg"
COMMIT="b0eee6f004e8df9556a9a9a0b42c9ebe0159c66b"
SRC_URI="https://github.com/paul-nameless/tg/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

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

