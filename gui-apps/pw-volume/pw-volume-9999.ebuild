# Copyright 2017-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
"

inherit cargo

DESCRIPTION="Basic interface to PipeWire volume controls"
HOMEPAGE="https://github.com/smasher164/pw-volume"

if [ ${PV} == "9999" ] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/smasher164/${PN}"
else
	SRC_URI="https://github.com/smasher164/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~ppc64 ~riscv"
fi

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

QA_FLAGS_IGNORED="usr/bin/${PN}"

LICENSE="MIT"
SLOT="0"

#RDEPEND="gui-libs/"
