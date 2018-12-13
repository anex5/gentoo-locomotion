# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

ETYPE="headers"
H_SUPPORTEDARCH="alpha amd64 arc arm arm64 avr32 bfin cris frv hexagon hppa ia64 m32r m68k metag microblaze mips mn10300 nios2 openrisc ppc ppc64 s390 score sh sparc tile x86 xtensa"

inherit kernel-2
detect_version

PATCH_VER="1"
SRC_URI="mirror://gentoo/gentoo-headers-base-${PV}.tar.xz
	https://dev.gentoo.org/~slyfox/distfiles/gentoo-headers-base-${PV}.tar.xz
	${PATCH_VER:+mirror://gentoo/gentoo-headers-${PV}-${PATCH_VER}.tar.xz}
	${PATCH_VER:+https://dev.gentoo.org/~slyfox/distfiles/gentoo-headers-${PV}-${PATCH_VER}.tar.xz}
"

KEYWORDS="*"

DEPEND="app-arch/xz-utils
	dev-lang/perl"
RDEPEND="!!media-sound/alsa-headers"

S=${WORKDIR}/gentoo-headers-base-${PV}

src_unpack() {
	unpack ${A}
}

src_prepare() {
	default
	[[ -n ${PATCH_VER} ]] && EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/${PV}
	epatch "${FILESDIR}/0001-CHROMIUM-media-headers-Import-V4L2-headers-from-Chro.patch"
	epatch "${FILESDIR}/0002-CHROMIUM-v4l-Add-VP8-low-level-decoder-API-controls.patch"
	epatch "${FILESDIR}/0003-v4l-add-pixelformat-change-event.patch"
	epatch "${FILESDIR}/0004-CHROMIUM-v4l-Add-VP9-low-level-decoder-API-controls.patch"
	epatch "${FILESDIR}/0005-CHROMIUM-v4l-Add-V4L2_CID_MPEG_VIDEO_H264_SPS_PPS_BE.patch"
	epatch "${FILESDIR}/0006-CHROMIUM-kernel-device_jail.patch"
	epatch "${FILESDIR}/0007-media-videodev2.h-add-IPU3-raw10-color.patch"
	epatch "${FILESDIR}/0008-videodev2.h-add-IPU3-meta-buffer-format.patch"
	epatch "${FILESDIR}/0009-uapi-intel-ipu3-Add-user-space-ABI-definitions.patch"
	epatch "${FILESDIR}/0010-virtwl-add-virtwl-driver.patch"
	epatch "${FILESDIR}/0011-BACKPORT-FROMLIST-v4l-Add-support-for-V4L2_BUF_TYPE_.patch"
	epatch "${FILESDIR}/0012-FROMLIST-media-rkisp1-Add-user-space-ABI-definitions.patch"
	epatch "${FILESDIR}/0013-FROMLIST-media-videodev2.h-v4l2-ioctl-add-rkisp1-met.patch"
	epatch "${FILESDIR}/0014-BACKPORT-add-qrtr-header-file.patch"
	epatch "${FILESDIR}/0015-BACKPORT-FROMGIT-media-v4l2-ctrl-Change-control-for-.patch"
	epatch "${FILESDIR}/0016-BACKPORT-FROMGIT-media-v4l2-ctrl-Add-control-for-VP9.patch"
	epatch "${FILESDIR}/0017-BACKPORT-FROMLIST-media-v4l-Add-JPEG_RAW-format.patch"
	epatch "${FILESDIR}/0018-BACKPORT-FROMLIST-v4l-Add-controls-for-jpeg-quantization-tables.patch"
	epatch "${FILESDIR}/0019-BACKPORT-media-uapi-linux-media.h-add-request-API.patch"
	epatch "${FILESDIR}/0020-BACKPORT-media-videodev2.h-add-request_fd-field-to-v.patch"
	epatch "${FILESDIR}/0021-BACKPORT-media-videodev2.h-Add-request_fd-field-to-v.patch"
	epatch "${FILESDIR}/0022-BACKPORT-media-videodev2.h-add-new-capabilities-for-.patch"
}

src_install() {
	kernel-2_src_install

	# hrm, build system sucks
	find "${ED}" '(' -name '.install' -o -name '*.cmd' ')' -delete
	find "${ED}" -depth -type d -delete 2>/dev/null
}

src_test() {
	# Make sure no uapi/ include paths are used by accident.
	egrep -r \
		-e '# *include.*["<]uapi/' \
		"${D}" && die "#include uapi/xxx detected"

	einfo "Possible unescaped attribute/type usage"
	egrep -r \
		-e '(^|[[:space:](])(asm|volatile|inline)[[:space:](]' \
		-e '\<([us](8|16|32|64))\>' \
		.

	einfo "Missing linux/types.h include"
	egrep -l -r -e '__[us](8|16|32|64)' "${ED}" | xargs grep -L linux/types.h

	emake ARCH=$(tc-arch-kernel) headers_check
}