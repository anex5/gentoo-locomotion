# Copyright 1999-2025 Gentoo Authors
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
IUSE="bluetooth calendar fonts network pipewire +shortcuts usb-storage systemd sway wifi ${MY_L10N[@]/#/l10n_}"

RESTRICT="mirror"

DEPEND="
	app-alternatives/sh
	gui-apps/rofi
	sys-apps/grep
	sys-apps/sed
	sys-apps/util-linux[systemd?]
	sys-apps/findutils
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
	network? (
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

	use systemd && ( sed -e 's/LOGIND="loginctl"/LOGIND="systemctl"/' -i urd-logout-menu || die "Sed failed" )

	local SNS=()
	use bluetooth && SNS+=( "urd-bluetooth-connections,bluetooth-symbolic" )
	use calendar && SNS+=( "urd-date-picker,x-office-calendar-symbolic" )
	use fonts && SNS+=( "urd-font-picker,font-select-symbolic" )
	use pipewire && SNS+=( "urd-pipewire-sinks,audio-speakers-symbolic" "urd-pipewire-sources,audio-input-microphone-symbolic" )
	use usb-storage && SNS+=( "urd-usbstor-mounter,drive-harddisk-usb-symbolic" )
	use sway && SNS+=( "urd-logout-menu,system-shutdown-symbolic" "urd-sway-display,video-display-symbolic" )
	use wifi && SNS+=( "urd-wifi-networks,network-wireless-symbolic" )
	use network && SNS+=( "urd-network-info,network-wired-symbolic" )

	for f in "${SNS[@]}"; do
		fn=${f%%,*}
		fi=${f##*,}
		doins "${fn}"
		#chmod 0755 "${f}"
		dosym "/usr/libexec/${PN}/${fn}" "/usr/bin/${fn}"
		if use shortcuts; then
			n="${fn##*urd-}"
			gn="${n/-/ }"
			sed -e "s/^\(Exec=\).*$/\1${fn}/" \
				-e "s/^\(Name=\).*$/\1${gn^}/" \
				-e "s/^\(Icon=\).*$/\1${fi}/" \
				-e "s/^\(GenericName=\).*$/\1${gn^}/" \
				"${FILESDIR}/urd.desktop" > "${T}/${fn}.desktop"
			for lang in "${MY_L10N[@]}"; do
				#[[ "${lang}" == "en-US" ]] && continue
				ln="$(sed -une "s|\[header_${n/-/_}\]\=\"\(.\+\)\"|\u\1|p" "${S}/common/langs/${lang/-/_}" || die)"
				lgn="$(sed -une "s|\[usage_${n/-/_}\]\=\"\(.\+\)\"|\u\1|p" "${S}/common/langs/${lang/-/_}" || die)"
				echo -e "Name[${lang/-/_}]=${ln}" >> "${T}/${fn}.desktop"
				echo -e "GenericName[${lang/-/_}]=${lgn}" >> "${T}/${fn}.desktop"
			done
			domenu "${T}/${fn}.desktop"
		fi
	done

	for lang in "${MY_L10N[@]}"; do
		if ! use ${lang/#/l10n_}; then rm "common/langs/${lang/-/_}" || die "removing ${lang} locale failed."; fi
	done
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
