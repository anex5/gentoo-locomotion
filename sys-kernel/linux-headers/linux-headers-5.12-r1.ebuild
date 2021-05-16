# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

ETYPE="headers"
H_SUPPORTEDARCH="alpha amd64 arc arm arm64 avr32 cris frv hexagon hppa ia64 m32r m68k metag microblaze mips mn10300 nios2 openrisc ppc ppc64 riscv s390 score sh sparc x86 xtensa"
inherit kernel-2
detect_version

PATCH_VER="1"
SRC_URI="${KERNEL_URI}
	${PATCH_VER:+mirror://gentoo/gentoo-headers-${PV}-${PATCH_VER}.tar.xz}
	${PATCH_VER:+https://dev.gentoo.org/~slyfox/distfiles/gentoo-headers-${PV}-${PATCH_VER}.tar.xz}
"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux"

DEPEND="app-arch/xz-utils
		dev-lang/perl"
RDEPEND=""

S=${WORKDIR}/linux-${PV}

#PATCHES=(
#	"${FILESDIR}/0000-CHROMIUM-v4l-Add-VP8-VP9-low-level-decoder-API-controls.patch"
#	"${FILESDIR}/0003-v4l-add-pixelformat-change-event.patch"
#	"${FILESDIR}/0007-media-videodev2.h-add-IPU3-raw10-color.patch"
#	"${FILESDIR}/0008-videodev2.h-add-IPU3-meta-buffer-format.patch"
#	"${FILESDIR}/0009-uapi-intel-ipu3-Add-user-space-ABI-definitions.patch"
#	"${FILESDIR}/0013-FROMLIST-media-videodev2.h-v4l2-ioctl-add-rkisp1-met.patch"
#	"${FILESDIR}/0017-BACKPORT-FROMLIST-media-v4l-Add-JPEG_RAW-format.patch"
#	"${FILESDIR}/0018-BACKPORT-FROMLIST-v4l-Add-controls-for-jpeg-quantization-tables.patch"
#	"${FILESDIR}/0028-UPSTREAM-media-pixfmt-Add-H264-Slice-format.patch"
#	"${FILESDIR}/0029-BACKPORT-FROMLIST-media-uapi-Add-VP8-stateless-decod.patch"
#	"${FILESDIR}/0037-BACKPORT-v4l2-add-V4L2_CID_MPEG_VIDEO_PREPEND_SPSPPS.patch"
#	"${FILESDIR}/0039-BACKPORT-net-qualcomm-rmnet-Export-mux_id-and-flags-to-netlink.patch"
#	"${FILESDIR}/0041-CHROMIUM-v4l-add-request-based-VP9-stateless-control.patch"
#	"${FILESDIR}/0042-CHROMIUM-linux-headers-update-headers-with-UVC-1.5-R.patch"
#)


src_prepare() {
	default

	[[ -n ${PATCH_VER} ]] && eapply "${FILESDIR}"/${PV}/*.patch
}

src_install() {
	kernel-2_src_install

	# hrm, build system sucks
	find "${ED}" '(' -name '.install' -o -name '*.cmd' ')' -delete
	find "${ED}" -depth -type d -delete 2>/dev/null
}

src_test() {
	emake ARCH=$(tc-arch-kernel) headers_check
}
