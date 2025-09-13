# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1

inherit distutils-r1

DESCRIPTION="Streaming multipart/form-data parser"
HOMEPAGE="https://github.com/siddhantgoel/streaming-form-data"
SRC_URI="https://github.com/siddhantgoel/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~x86 ~arm"

RDEPEND="${PYTHON_DEPS}"

RESTRICT="test mirror"
