# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )

inherit distutils-r1

DESCRIPTION="Streaming multipart/form-data parser"
HOMEPAGE="https://github.com/siddhantgoel/${PN}"
SRC_URI="https://github.com/siddhantgoel/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~x86 ~arm"

RDEPEND="${PYTHON_DEPS}"

RESTRICT="test mirror"
