# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info toolchain-funcs

DESCRIPTION="Control AMD Overdrive settings with or without X."
HOMEPAGE="https://github.com/matszpk/amdcovc"

if [ ${PR} == "r0" ]; then 
	PR=""
fi

if [ ${PV} == "9999" ] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/matszpk/${PN}"
else
	SRC_URI="https://github.com/matszpk/${PN}/archive/${PV}${PR/r/.}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="catalyst"

DEPEND="
	catalyst? ( x11-libs/amd-adl-sdk )
	sys-libs/ncurses
	sys-apps/pciutils
"

RDEPEND="${DEPEND}"

BDEPEND="virtual/pkgconfig"

S=${WORKDIR}/${P}${PR/r/.}

src_compile() {
    local myemakeargs=(
		# it's a non-standard build system
		$(usex catalyst -DHAVE_ADLSDK=1 -DHAVE_ADLSDK=0)
		-DHAVE_TERMINFO=1
	)    

    CC=$(tc-getCC) CFLAGS=\"${myemakeargs[@]}\" emake
}

src_install() {
	local DOCS=( README )
	insinto /usr/bin
	dobin ${PN}
	dodoc README.md
}

pkg_postinst() {
   	elog "To enable overclocking support in amdgpu driver use following kernel cmdline: amdgpu.ppfeaturemask=0xffffffff"
}
