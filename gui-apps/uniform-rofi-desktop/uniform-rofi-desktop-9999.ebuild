# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils

DESCRIPTION="Asset of scripts which provides uniform desktop utilities"
HOMEPAGE="https://github.com/anex5/uniform-rofi-desktop"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/anex5/uniform-rofi-desktop.git"
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
#else
#	SRC_URI="https://github.com/anex5/uniform-rofi-desktop/archive/v${PV}.tar.gz -> ${P}.tar.gz"
#	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
fi

LICENSE="MIT"
SLOT="0"
MY_L10N=( "en-US" "ru-RU" )
IUSE="bluetooth calendar fonts pipewire +shortcuts usb-storage sway wifi ${MY_L10N[@]/#/l10n_}"

RESTRICT="mirror"

DEPEND="
	app-alternatives/sh
	gui-apps/rofi
	sys-apps/grep
	sys-apps/sed
	sys-apps/util-linux
	media-fonts/nerd-fonts
	bluetooth? (
		sys-apps/hwdata
		net-wireless/bluez
	)
	pipewire? (
		media-video/pipewire
		media-video/wireplumber
	)
	usb-storage? (
		sys-apps/hwdata
		sys-fs/udisks
	)
	sway? ( ||
		(
			gui-wm/sway
			gui-wm/swayfx
		)
	)
	wifi? (
		sys-apps/hwdata
		net-misc/networkmanager
	)
"
RDEPEND="${DEPEND}"

#DOCS=(README.md LICENSE)

src_compile() {
	:
}

src_install() {
	dodir /usr/libexec/${PN}
	insinto /usr/libexec/${PN}
	insopts -m0755
	doins -r "common"
	doins "urd-confirm"
	doins "urd-prompt"
	local SNS=()
	use bluetooth && SNS+=( "urd-bluetooth-connections" )
	use calendar && SNS+=( "urd-date-picker" )
	use fonts && SNS+=( "urd-font-picker" )
	use pipewire && SNS+=( "urd-pipewire-sink" "urd-pipewire-source" )
	use usb-storage && SNS+=( "urd-usbstor-mounter" )
	use sway && SNS+=( "urd-logout-menu" "urd-sway-display" )
	use wifi && SNS+=( "urd-wifi-network" )
	for f in ${SNS[@]}; do
		doins "${f}"
		#chmod 0755 "${f}"
		dosym "/usr/libexec/${PN}/${f}" "/usr/bin/${f}"
		if use shortcuts; then
			n="${f##*urd-}"
			gn="${n/-/ }"
			sed -e "s/^\(Exec=\)/\1${f}/" \
				-e "s/^\(Name=\)/\1${gn^}/" \
				-e "s/^\(GenericName=\)/\1${gn^}/" \
				"${FILESDIR}/urd.desktop" > "${T}/${f}.desktop"
			domenu "${T}/${f}.desktop"
		fi
	done

	for f in "${MY_L10N[@]}"; do
		if ! use ${f/#/l10n_}; then rm "common/langs/${f/-/_}" || die "removing ${f} locale failed."; fi
	done
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}