# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QA_PKGCONFIG_VERSION="$(ver_cut 1-3)"

# Release signer can vary per version but not clear if others will be doing
# them in future, so gone with Even Rouault for now as he does other geosci
# stuff too like PROJ, GDAL. Previous release manager of TIFF was
# GraphicsMagick maintainer Bob Friesenhahn. Please be careful when verifying
# who made releases.
VERIFY_SIG_OPENPGP_KEY_PATH="${BROOT}"/usr/share/openpgp-keys/rouault.asc
inherit libtool multilib-minimal verify-sig flag-o-matic

MY_P="${P/_rc/rc}"
DESCRIPTION="Tag Image File Format (TIFF) library"
HOMEPAGE="http://libtiff.maptools.org"
SRC_URI="https://download.osgeo.org/libtiff/${MY_P}.tar.xz"
SRC_URI+=" verify-sig? ( https://download.osgeo.org/libtiff/${MY_P}.tar.xz.sig )"
S="${WORKDIR}/${PN}-$(ver_cut 1-3)"

LICENSE="libtiff"
SLOT="0/6"
if [[ ${PV} != *_rc* ]] ; then
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
fi
IUSE="X +cxx doc contrib jbig jpeg lerc lzma opengl static-libs test tools webp zlib zstd"
RESTRICT="!test? ( test )"

# bug #483132
REQUIRED_USE="
	opengl? ( X )
	test? ( jpeg )
"

RDEPEND="
	jbig? ( >=media-libs/jbigkit-2.1:=[${MULTILIB_USEDEP}] )
	jpeg? ( media-libs/libjpeg-turbo:=[${MULTILIB_USEDEP}] )
	lzma? ( >=app-arch/xz-utils-5.0.5-r1[${MULTILIB_USEDEP}] )
	opengl? ( media-libs/freeglut )
	webp? ( media-libs/libwebp:=[${MULTILIB_USEDEP}] )
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )
	zstd? ( >=app-arch/zstd-1.3.7-r1:=[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	verify-sig? ( sec-keys/openpgp-keys-evenrouault )
	virtual/pkgconfig
"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/tiffconf.h
)

src_prepare() {
	default

	# Added to fix cross-compilation
	elibtoolize
}

multilib_src_configure() {
	append-lfs-flags

	local myeconfargs=(
		"VERBOSE=1"
		"PREFIX=${EPREFIX}/usr"
		"LIBDIR=${EPREFIX}/usr/$(get_libdir)"
		--disable-sphinx
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF}
		$(use_with X x)
		$(use_enable cxx)
		$(use_enable jbig)
		$(use_enable jpeg)
		$(multilib_native_use_enable opengl)
		$(use_enable lzma)
		$(use_enable static-libs static)
		$(use_enable test tests)
		$(use_enable webp)
		$(use_enable zlib)
		$(use_enable zstd)
		$(use_enable lerc)

		$(multilib_native_use_enable doc docs)
		$(multilib_native_use_enable contrib contrib)
		$(multilib_native_use_enable tools tools)
	)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete || die
}
