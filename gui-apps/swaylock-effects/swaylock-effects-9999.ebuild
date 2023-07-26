# Copyright 1999-2023 Gentoo foundation
# Distributed under the terms of the ISC License

EAPI=8

inherit meson shell-completion

DESCRIPTION="Screen locker for Wayland"
HOMEPAGE="https://github.com/jirutka/swaylock-effects"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/jirutka/swaylock-effects.git"
	KEYWORDS="-*"
else
	SRC_URI="https://github.com/jirutka/swaylock-effects/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}"/${PN}-${PV}
	KEYWORDS="~amd64 ~arm64 ~arm ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="zsh-completion bash-completion fish-completion +gdk-pixbuf pam man cpu_flags_x86_sse"

DEPEND="
	dev-libs/wayland
	x11-libs/cairo
	x11-libs/libxkbcommon
	gdk-pixbuf? ( x11-libs/gdk-pixbuf:2 )
	pam? ( sys-libs/pam )
"
RDEPEND="${DEPEND}
	!gui-apps/swaylock
"
BDEPEND="
	man? ( app-text/scdoc )
	>=dev-libs/wayland-protocols-1.14
	virtual/pkgconfig
"
RESTRICT="mirror"

src_configure() {
	local emesonargs=(
		$(meson_feature man man-pages)
		$(meson_feature pam)
		$(meson_feature gdk-pixbuf)
		$(meson_use zsh-completion zsh-completions)
		$(meson_use bash-completion bash-completions)
		$(meson_use fish-completion fish-completions)
		$(meson_use cpu_flags_x86_sse sse)
		"-Dwerror=false"
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	use bash-completion && newbashcomp completions/bash/swaylock swaylock
	use zsh-completion && newzshcomp completions/zsh/_swaylock _swaylock
	use fish-completion && newfishcomp completions/fish/swaylock.fish swaylock.fish
	if ! use pam; then
		fowners root:0 ${ED}/bin/swaylock
		fperms 4511 ${ED}/bin/swaylock
	fi
}
