# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1

DESCRIPTION="A utility for batch-normalizing audio using ffmpeg"
HOMEPAGE="https://github.com/slhck/ffmpeg-normalize"
SRC_URI="https://github.com/slhck/ffmpeg-normalize/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/ffmpeg-progress-yield[${PYTHON_USEDEP}]
	>=media-video/ffmpeg-4.4:=
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

RESTRICT="mirror"
