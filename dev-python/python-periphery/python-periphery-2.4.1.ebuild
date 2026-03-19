# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="A pure Python 2/3 library for peripheral I/O (GPIO, LED, PWM, SPI, I2C, MMIO, Serial) in Linux"
HOMEPAGE="https://github.com/vsergeev/python-periphery"
SRC_URI="https://github.com/vsergeev/python-periphery/archive/refs/tags/v${PV}/${P}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~riscv x86"
RESTRICT="mirror test"

RDEPEND="${PYTHON_DEPS}"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"

