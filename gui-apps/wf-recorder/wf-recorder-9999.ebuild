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
	COMMIT="2ad4ee777d1fb0423648183acb863d85a29f2f40"
	SRC_URI="https://github.com/ammen99/wf-recorder/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
	S=${WORKDIR}/${PN}-${COMMIT}
fi

IUSE="debug fish-completion man pipewire pulseaudio"
LICENSE="MIT"
SLOT="0"

DEPEND="
	dev-libs/wayland
	>=dev-libs/wayland-protocols-1.14
	pulseaudio? ( media-sound/pulseaudio )
	pipewire? ( >=media-video/pipewire-1.0.5 )
	media-video/ffmpeg[pulseaudio?,x264,drm]
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-vcs/git
	virtual/pkgconfig
	dev-util/wayland-scanner
"

RESTRICT="mirror"

src_prepare() {
	default
    use man || ( sed -e "/^install_data('manpage/,/ 'man1'))$/d" -i meson.build || die )
    use fish-completion || ( sed -e "/^install_data('completions/,/share\/fish\/fish\/vendor_completions.d\/'))$/d" -i meson.build || die )
}

src_configure() {
	local emesonargs=(
		-Dbuildtype="$(usex debug debug plain)"
		-Db_ndebug="$(usex debug false true)"
		--prefix='/usr'
		-Ddefault_codec='libx264'
#		-Ddefault_audio_codec='flac'
		$(meson_feature pulseaudio pulse)
		$(meson_feature pipewire pipewire)
	)
	meson_src_configure
}
