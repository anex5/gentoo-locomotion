# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib

NV_VER="575.64.05"
COMMIT_HASH="e02b9c5c714f35a7576f0c1e549327e060fc7903"

DESCRIPTION="A VA-API implemention using NVIDIA's NVDEC, specifically designed to be used by Firefox"
HOMEPAGE="https://github.com/elFarto/nvidia-vaapi-driver"
#SRC_URI="https://github.com/elFarto/nvidia-vaapi-driver/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="
	https://github.com/elFarto/nvidia-vaapi-driver/archive/${COMMIT_HASH}.tar.gz -> ${P}-${COMMIT_HASH}.tar.gz
	kernel-open? ( https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/${NV_VER}.tar.gz -> open-gpu-kernel-modules-${NV_VER}.tar.gz )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="kernel-open"

RDEPEND="
	>=x11-drivers/nvidia-drivers-${NV_VER}:=[kernel-open?]
	>=media-libs/libva-2.20
	media-libs/libglvnd
	>=x11-libs/libdrm-2.4.60
"
BDEPEND="
	dev-build/meson
	>=media-libs/nv-codec-headers-12.1.14:=
	>=media-video/ffmpeg-6.1:=[nvenc]
	virtual/pkgconfig
"

RESTRICT="mirror"

S=${WORKDIR}/${PN}-${COMMIT_HASH}

src_prepare() {
    default
    if use kernel-open; then
        echo "Enabeling direct access.."
        "./${S}/extract_headers.sh" "${WORKDIR}/open-gpu-kernel-modules-${NV_VER}"
    fi
}

pkg_postinst() {
	elog "This library requires special configuration! See "
	elog "${HOMEPAGE}"

	# Source: https://github.com/elFarto/nvidia-vaapi-driver/blob/v0.0.13/src/backend-common.c#L13
	elog "If vaapi drivers fail to load, then make sure that you are"
	elog "passing the correct parameters to the kernel."
	elog "nvidia_drm.modeset should be set to 1."

	elog "Check the wiki page for more information: "
	elog "https://wiki.gentoo.org/wiki/VAAPI"
}
