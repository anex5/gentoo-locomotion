# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

DESCRIPTION="Run an ffmpeg command with its progress yielded"
HOMEPAGE="https://pypi.org/project/ffmpeg-progress-yield"
SRC_URI="https://github.com/slhck/ffmpeg-progress-yield/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/tqdm-4.38.0[${PYTHON_USEDEP}]
	>=dev-python/colorama-0.4.3[${PYTHON_USEDEP}]
	>=media-video/ffmpeg-4.4444"

RESTRICT="mirror"
