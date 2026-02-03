# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 autotools toolchain-funcs

DESCRIPTION="Utilities to to extract and rebuild firmware images for various embedded devices"
HOMEPAGE="https://code.google.com/p/firmware-mod-kit/wiki/Documentation"
EGIT_REPO_URI="https://github.com/rampageX/firmware-mod-kit"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="doc"

DEPEND="
	app-arch/xz
	sys-libs/zlib
"
RDEPEND="${DEPEND}"
#BDEPEND="app-text/dos2unix"

PATCHES="${FILESDIR}"/wrt54gv5_img-fix-printf.patch

#S=${WORKDIR}/${P}/src

src_prepare() {
	#sed -e 's|struct global|extern struct global|' -i "${S}"/src/webcomp-tools/common.h || die
	#sed -e '12 i\struct global globals = {};' -i "${S}"/src/webcomp-tools/common.c || die
	sed -e 's/BIG_ENDIAN/__BIG_ENDIAN/g' -e 's/LITTLE_ENDIAN/__LITTLE_ENDIAN/g' -i "${S}"/src/webcomp-tools/common.c || die
	sed -e '/CXX := g++/d' -i "${S}"/src/Makefile -i "${S}"/src/wrt_vx_imgtool/Makefile || die
	sed -e 's/gcc/\$\(CC\)/' -i "${S}"/src/bff/Makefile || die

	sed -e 's|u_int8_t|uint8_t|g' -e 's|u_int16_t|uint16_t|g' -e 's|u_int32_t|uint32_t|g' \
		-i "${S}"/src/asustrx.c -i "${S}"/src/untrx.h \
		-i "${S}"/src/firmware-tools/mkfwimage2.c -i "${S}"/src/firmware-tools/fw.h || die

#	dos2unix ${S}/src/others/squashfs-3.4-cisco/squashfs-tools/mksquashfs.c
	default
}

src_configure(){
	cd src && eautoreconf
}

src_compile() {
	cd src && emake CC="$(tc-getCC)" asustrx addpattern untrx motorola-bin splitter3 && \
		emake CC="$(tc-getCC)" -C ./wrt_vx_imgtool && \
		emake CC="$(tc-getCC)" -C ./firmware-tools && \
		emake CC="$(tc-getCC)" -C ./tpl-tool/src && \
		emake CC="$(tc-getCC)" -C ./crcalc && \
		emake CC="$(tc-getCC)" -C ./webcomp-tools && \
		emake CC="$(tc-getCC)" -C ./bff
}

src_install() {
	cd src
	find ${S} -name '*.o' -delete

	dobin asustrx addpattern untrx motorola-bin splitter3 \
		wrt_vx_imgtool/wrt_vx_imgtool \
		firmware-tools/{buffalo-enc,unwdk.py,unzlib.py} \
		tpl-tool/src/tpl-tool \
		crcalc/{crcalc,crc32} \
		webcomp-tools/webdecomp \
		bff/{bff_huffman_decompress,bffxtractor.py}
	use doc && default
}
