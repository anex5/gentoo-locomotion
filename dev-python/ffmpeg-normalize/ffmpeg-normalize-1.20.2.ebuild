# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3_{6..9} )

inherit distutils-r1 git-r3

DESCRIPTION="A utility for batch-normalizing audio using ffmpeg"
HOMEPAGE="https://github.com/slhck/ffmpeg-normalize"
EGIT_REPO_URI="https://github.com/slhck/ffmpeg-normalize"
EGIT_COMMIT="ff587733e033ed036c081bc5bf23881f2aeca04f"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-python/tqdm[${PYTHON_USEDEP}]
	>=media-video/ffmpeg-3.1:=
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

