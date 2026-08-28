# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info toolchain-funcs

DESCRIPTION="Control AMD Overdrive settings with or without X"
HOMEPAGE="https://github.com/matszpk/amdcovc"

if [ ${PV} == "9999" ] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/matszpk/amdcovc"
else
	SRC_URI="https://github.com/matszpk/amdcovc/archive/${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="-* ~amd64"
	#S="${WORKDIR}/${P}"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="catalyst"
RESTRICT="mirror"

DEPEND="
	catalyst? ( dev-libs/amdgpu-pro-opencl )
	sys-libs/ncurses
	sys-apps/pciutils
"

RDEPEND="${DEPEND}"

BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	# Delete hardcoded CXX
	sed -e "/^CXX = g++$/d" -i Makefile || die
	if tc-is-clang; then
		eapply "${FILESDIR}"/amdcovc-9999-fix-noreturn-pciAccessError.patch
	fi
}

src_compile() {
	local myemakeargs=(
		-DHAVE_ADLSDK="$(usex catalyst 1 0)"
		-DHAVE_TERMINFO=1
	)

	CXX=$(tc-getCXX) CFLAGS="${CXXFLAGS} ${myemakeargs[@]}" emake
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
