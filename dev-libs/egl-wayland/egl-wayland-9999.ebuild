# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools git-r3 libtool toolchain-funcs

EGIT_REPO_URI="https://github.com/NVIDIA/egl-wayland.git"

if [[ ${PV} = *9999* ]]; then
	EGIT_BRANCH="master"
else
	EGIT_COMMIT="refs/tags/${PV/_*/}"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
fi

DESCRIPTION="EGLStream-based Wayland external platform"
HOMEPAGE="https://nvidia.com"

LICENSE="MIT"
SLOT="0"
IUSE="static-libs debug"

BDEPEND="
	virtual/pkgconfig
	dev-vcs/git
	sys-devel/autogen
	x11-drivers/nvidia-drivers
"
DEPEND="
	>=dev-libs/wayland-1.11.0
	media-libs/mesa[wayland,egl]
	
"
RDEPEND="${DEPEND}
	!<media-libs/mesa-18.1.1-r1
"

src_configure(){
	./autogen.sh || die
}

src_compile(){
	emake
}

src_install(){
	if [[ ${PV} = *9999* ]]; then
		VER=$(cat ${S}/wayland-eglstream.pc | awk '/Version/ { print $2 }' )
	else
		VER=${PV}
	fi
	into .libs
	dolib.so libnvidia-egl-wayland.so.${VER}
	local v
	for v in libnvidia-egl-wayland.so{,.{${VER%%.*},${VER%.*}}} ; do
		dosym llibnvidia-egl-wayland.so.${VER} /usr/$(get_libdir)/${v}
	done
	use static-libs && dolib.a libnvidia-egl-wayland.a
	
	insinto "${EPREFIX}/usr/$(get_libdir)"
	doins "${S}/.libs/"*.so*
	insinto "${EPREFIX}/usr/local/share/wayland-eglstream"
	doins "${S}/wayland-eglstream/"*.xml
	insinto "${EPREFIX}/usr/$(get_libdir)/pkgconfig"
	doins "${S}/"*.pc
}