# Copyright 2017-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
atty-0.2.14
ansi_term-0.11.0
anyhow-1.0.56
bitflags-1.3.2
cfg-if-1.0.0
clap-2.33.3
hermit-abi-0.1.19
itoa-0.4.8
libc-0.2.107
proc-macro2-1.0.32
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
quote-1.0.10
quoted_printable-0.4.5
ryu-1.0.5
serde-1.0.130
serde_derive-1.0.130
serde_json-1.0.70
strsim-0.8.0
syn-1.0.81
test-case-2.1.0
test-case-macros-2.1.0
textwrap-0.11.0
unicode-width-0.1.9
unicode-xid-0.2.2
vec_map-0.8.2
version_check-0.9.4
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.5
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="Basic interface to PipeWire volume controls"
HOMEPAGE="https://github.com/smasher164/pw-volume"

if [ ${PV} == "9999" ] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/smasher164/${PN}"
else
	SRC_URI="https://github.com/smasher164/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~arm64 ~arm ~ppc64 ~riscv ~x86"
fi

RESTRICT="mirror"

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
