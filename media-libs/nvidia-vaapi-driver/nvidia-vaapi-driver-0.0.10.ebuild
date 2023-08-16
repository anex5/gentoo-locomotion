# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

NV_VER="535.98"
COMMIT_HASH="59aecf1d06de559a0561afd7c9c31eaa37e64040"

DESCRIPTION="A VA-API implemention using NVIDIA's NVDEC, specifically designed to be used by Firefox"
HOMEPAGE="https://github.com/elFarto/nvidia-vaapi-driver"
#SRC_URI="https://github.com/elFarto/nvidia-vaapi-driver/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="
	https://github.com/elFarto/nvidia-vaapi-driver/archive/${COMMIT_HASH}.tar.gz -> ${P}-${COMMIT_HASH}.tar.gz
	https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/${NV_VER}.tar.gz -> open-gpu-kernel-modules-${NV_VER}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+direct"

RDEPEND="
	x11-drivers/nvidia-drivers
	media-libs/libva
"
BDEPEND="
	dev-util/meson
	media-libs/nv-codec-headers
	media-video/ffmpeg[nvenc]
"

RESTRICT="mirror"

#PATCHES=( "${FILESDIR}/${PN}-0.0.8-install-path.patch" )

S=${WORKDIR}/${PN}-${COMMIT_HASH}

src_prepare() {
    default
    cp ${FILESDIR}/99nvidia-vaapi ${S}/99nvidia-vaapi
    if use direct; then
        echo "Enabeling direct access.."
        "./${S}/extract_headers.sh" "${WORKDIR}/open-gpu-kernel-modules-${NV_VER}"
    fi
}

src_install() {
    meson_src_install
    #dosym /usr/lib64/dri/nvidia_drv_video.so /usr/lib64/va/drivers/nvidia_drv_video.so
}

pkg_postinst() {
	ewarn "This library requires special configuration! See "
	ewarn "${HOMEPAGE}"
	ewarn "The direct backend is currently required on NVIDIA driver series 525 due to a regression"
	ewarn "See ${HOMEPAGE}/issues/126"
}
