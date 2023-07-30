# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Screen recorder for wlroots-based compositors"
HOMEPAGE="https://github.com/ammen99/wf-recorder"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ammen99/wf-recorder.git"
else
	COMMIT="a40f9ad9f09fa142092c67e19f8679246b7ad8af"
	SRC_URI="https://github.com/ammen99/wf-recorder/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
	S=${WORKDIR}/${PN}-${COMMIT}
fi

IUSE="debug pulseaudio"
LICENSE="MIT"
SLOT="0"

DEPEND="
	dev-libs/wayland
	pulseaudio? ( media-sound/pulseaudio )
	media-video/ffmpeg[pulseaudio?,x264]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	dev-libs/wayland-protocols
"

RESTRICT="mirror"

src_configure() {
	local emesonargs=(
		--buildtype $(usex debug debug release)
		--prefix='/usr'
		-Ddefault_codec='libx264'
#		-Ddefault_audio_codec='flac'
		$(meson_feature pulseaudio pulse)
	)
	meson_src_configure
}
