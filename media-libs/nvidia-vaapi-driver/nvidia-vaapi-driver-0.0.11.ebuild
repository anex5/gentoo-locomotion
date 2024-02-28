# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

NV_VER="545.29.06"
COMMIT_HASH="746d5510eabe949def3c79acc856393596d75cf5"

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
IUSE="-kernel-open"

RDEPEND="
	>=x11-drivers/nvidia-drivers-${NV_VER}:=[kernel-open?]
	>=media-libs/libva-2.20
"
BDEPEND="
	dev-build/meson
	>=media-libs/nv-codec-headers-12.1.14:=
	>=media-video/ffmpeg-6.1:=[nvenc]
"

RESTRICT="mirror"

#PATCHES=( "${FILESDIR}/${PN}-0.0.8-install-path.patch" )

S=${WORKDIR}/${PN}-${COMMIT_HASH}

src_prepare() {
    default
    if use kernel-open; then
        echo "Enabeling direct access.."
        "./${S}/extract_headers.sh" "${WORKDIR}/open-gpu-kernel-modules-${NV_VER}"
    fi
}

pkg_postinst() {
	ewarn "This library requires special configuration! See "
	ewarn "${HOMEPAGE}"
	ewarn "The direct backend is currently required on NVIDIA driver series 525 due to a regression"
	ewarn "See ${HOMEPAGE}/issues/126"
}
