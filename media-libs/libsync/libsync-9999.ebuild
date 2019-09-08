# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
EAPI="7" 
inherit git-r3 multilib 
DESCRIPTION="Library for Android sync objects"
HOMEPAGE="https://android.googlesource.com/platform/system/core/libsync"
EGIT_REPO_URI="https://chromium.googlesource.com/aosp/platform/system/core/libsync"
EGIT_COMMIT="f4f4387b6bf2387efbcfd1453af4892e8982faf6"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
RDEPEND="!media-libs/arc-camera3-libsync"

src_prepare() {
	default
	cp "${FILESDIR}/Makefile" "${S}" || die "Copying Makefile"
	cp "${FILESDIR}/strlcpy.c" "${S}" || die "Copying strlcpy.c"
	cp "${FILESDIR}/libsync.pc.template" "${S}" || die "Copying libsync.pc.template"
	eapply "${FILESDIR}/0001-libsync-add-prototype-for-strlcpy.patch" || die "patching "
}

src_configure() {
	default
	export GENTOO_LIBDIR=$(get_libdir)
	tc-export CC
}