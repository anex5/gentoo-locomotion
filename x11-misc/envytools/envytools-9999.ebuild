# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Tools for people envious of nvidia's blob driver"
HOMEPAGE="https://envytools.readthedocs.io/en/latest/"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/envytools/envytools"
else
	COMMIT="f102b82381f3f11cee113d16374c87091db039d9"
	SRC_URI="https://github.com/envytools/envytools/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}"/${PN}-${COMMIT}
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"

IUSE="+hwtest +nva +vdpau"

RDEPEND="
	dev-libs/libxml2
	x11-libs/libdrm
	sys-libs/libseccomp
	x11-libs/libpciaccess
	nva? (
		x11-libs/libX11
		x11-libs/libXext
	)
	vdpau? (
		x11-libs/libX11
		x11-libs/libvdpau
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	sys-devel/bison
	sys-devel/flex
"

RESTRICT="mirror"

DOCS=( README.rst )

PATCHES=(
	"${FILESDIR}/${PN}"-bison.patch
	"${FILESDIR}/${PN}"-pr194.patch
	"${FILESDIR}/${PN}"-pr206.patch
	"${FILESDIR}/${PN}"-pr225.patch
)

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DDISABLE_HWTEST=$(usex !hwtest)
		-DDISABLE_NVA=$(usex !nva)
		-DDISABLE_VDPOW=$(usex !vdpau)
		-DDOC_PATH="/usr/share/doc/${PF}"
	)
	cmake_src_configure
}

src_install() {
	default
	cmake_src_install
	dolib.so ${BUILD_DIR}/cgen/libcgen.so
	dolib.so ${BUILD_DIR}/rnn/libseq.so
}
