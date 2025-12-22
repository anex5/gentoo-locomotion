# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER=3.3-gtk3
inherit autotools toolchain-funcs wxwidgets desktop

DESCRIPTION="wxWidgets-based EDID (Extended Display Identification Data) editor"
HOMEPAGE="https://wxedid.sourceforge.io"
SRC_URI="https://downloads.sourceforge.net/${PN}/${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~riscv ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="x11-libs/wxGTK:${WX_GTK_VER}"

#QA_PRESTRIPPED="usr/bin/wxedid"

S="${WORKDIR}/${PN}-${PV}"

PATCHES=(
	"${FILESDIR}"/${PN}_xdg_cfg.patch
)

pkg_setup() {
	setup-wxwidgets
}

src_prepare() {
	default
	eautoreconf
	if use elibc_musl; then
		sed -e '/echo -en \"#include <sys\/cdefs\.h>\\n\" >> \$out_scp_src/d' \
			-e 's/__BEGIN_DECLS\\n\\n/#ifdef __cplusplus\\nextern "C" {\\n#endif/g' \
			-e 's/__END_DECLS\\n\\n/#ifdef __cplusplus\\n}\\n#endif/g' \
			-i src/rcode/rcd_autogen || die
		sed -e '/#include <sys\/cdefs\.h>/d' \
			-e 's/__BEGIN_DECLS/#ifdef __cplusplus\nextern "C" {\n#endif/g' \
			-e 's/__END_DECLS/#ifdef __cplusplus\n}\n#endif/g' \
			-i src/rcode/{rcode.h,rcd_alias.h,rcode_scp.h,rcd_scp.tmp.c,rcd_scp.tmp.h,rcd_fn.tmp.c} || die
	fi
	# Strip hardcoded oflags and lto
	sed -e 's/-O1 -flto//' -i configure.ac || die
}

src_configure() {
	tc-export CXX
	tc-export_build_env BUILD_CXX
	export RCDGEN_CXXCPP="${BUILD_CXX}"
	econf --enable-shared
	#use elibc_musl && append-cxxflags -D__EXPORTED_HEADERS__
	strip-unsupported-flags
	default
}

src_install() {
	default
	insinto /usr/share/applications
	domenu "${FILESDIR}/net.sourceforge.wxEDID.desktop"
	doicon -s scalable "${FILESDIR}/net.sourceforge.wxEDID.svg"
}
