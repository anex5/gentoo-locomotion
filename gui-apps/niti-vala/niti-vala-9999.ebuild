# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 gnome2-utils meson systemd vala xdg

NITI_SERVICES=(
	"abooster"
	"applications"
	"autoprofile"
	"audio"
	"backlight"
	"bluetooth"
	"caffeine"
	"diag"
	"eds"
	"hidpp"
	"layout"
	"matugen"
	"mpris"
	"network"
	"niri"
	"notifications"
	"pluginreg"
	"pwrec"
	"secret-agent"
	"systemtray"
	"theme"
	"udisks"
	"upower"
	"vpn"
)

NITI_MODULES=(
	"calendar"
	"hotkeys"
	"launcher"
	"notifications"
	"quickcenter"
)

NITI_WIDGETS=(
	"caffeine"
	"clock"
	"disks"
	"hotkeys"
	"keyboard"
	"layouts"
	"media"
	"power"
	"quickbutton"
	"recording"
	"systeminfo"
	"tasks"
	"tray"
	"vitals"
	"workspaces"
)

MY_PN="NitiVala"
MY_PV="0.1.0"
DESCRIPTION="A port of Niti wayland pannel for native Vala/GTK4, with no CGo/GC layer"
HOMEPAGE="https://altlinux.space/plafonlinux/NitiVala"

EGIT_REPO_URI="https://altlinux.space/plafonlinux/NitiVala.git"
EGIT_CHECKOUT_DIR="${S}/subprojects"

if [[ ${PV} == *9999* ]]; then
	KEYWORDS=""
else
	#EGIT_COMMIT="v${PV//_p/-}"
	EGIT_COMMIT="0be9e4fd779f5dd1478461003e415ef5144936de"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="lto pgo test systemd"

RESTRICT="
	!test? ( test )
	mirror
"

COMMON_DEPEND="
	app-crypt/libsecret
	gui-libs/gtk:4=[introspection]
	>=gui-libs/libadwaita-1.6:1=[introspection]
	>=media-libs/freetype-2.13.2:=[bzip2,harfbuzz,png]
	>=media-libs/harfbuzz-8.4.0:=[truetype]
	dev-libs/json-glib:0=
	dev-libs/libpeas:2=
	dev-libs/wayland
	gui-libs/gtk4-layer-shell:=
	media-libs/libpulse
	gnome-extra/evolution-data-server[introspection,vala]
	net-misc/networkmanager[introspection,vala]
	systemd? ( sys-apps/systemd:= )
"
DEPEND="
	${COMMON_DEPEND}
"
RDEPEND="
	${COMMON_DEPEND}
"
BDEPEND="
	dev-util/glib-utils
	virtual/pkgconfig
	dev-libs/glib:2
	sys-devel/gettext
	dev-libs/gobject-introspection
	$(vala_depend)
"

src_prepare() {
	default
	vala_setup
	# Set version
	sed -e "s/version: '0.0.0'/version: \'${MY_PV}\'/" \
		"${FILESDIR}"/meson.build.in > "${S}"/meson.build || die

	# Flatten project folders structure due to meson subprojects reqs
	pushd "${S}"/subprojects || die
	for subdir in services modules widgets; do
		find "${subdir}" -mindepth 1 -maxdepth 1 -type d -exec sh -c 'mv -v "${0}" "${1}-${0##*/}"' {} ${subdir} \;
		rm -vr "${subdir}" || die
	done
	# Fix access violation for subprojects
	ln -snf ../data services-diag/data || die
	ln -snf ../data core/data || die

	# Fix meson.build files for subprojects
	# core abooster applications audio backlight bluetooth caffeine calendar diag disks eds hidpp hotkeys keyboard launcher layout layouts matugen media mpris network niri notifications pluginreg power pwrec quickbutton recording secret-agent systeminfo systemtray tasks theme tray udisks upower vitals vpn workspaces

	for proj in ${NITI_SERVICES[*]}; do
		sed -e "s/\.\.\/\.\.\/data\/org\.altlinux\.Niti\.Diag1\.xml/data\/org.altlinux.Niti.Diag1.xml/" \
			-e "s/\blib\b/${proj//-/_}_lib/g" \
			-e "\$a niti_${proj//-/_}_dep \= declare_dependency(link_with\: ${proj//-/_}_lib\, include_directories\: include_directories(\x27.\x27))" \
			-i "services-${proj}/meson.build" || die
	done

	for proj in calendar hotkeys launcher notifications; do
		sed -e "s/\blib\b/${proj//-/_}_lib/g" \
			-e "\$a niti_${proj//-/_}_dep \= declare_dependency(link_with\: ${proj//-/_}_lib\, include_directories\: include_directories(\x27.\x27))" \
			-i "modules-${proj}/meson.build" || die
	done

	sed -e "s/niti_notifications_dep/niti_notif_dep/" -i "modules-notifications/meson.build" || die

	sed -e "s/\blib\b/quickcenter_lib/g" \
		-e "\$a niti_quickcenter_dep \= declare_dependency(link_with\: quickcenter_lib\, include_directories\: include_directories(\x27./\x27))" \
		-i "modules-quickcenter/src/meson.build" || die

	sed -e "s/\blib\b/widget_lib/g" \
		-e "\$a niti_widget_dep \= declare_dependency(link_with\: widget_lib\, include_directories\: include_directories(\x27.\x27))" \
		-i "api/meson.build" || die

	sed -e "s/\.\.\/data\/icons\/org.plafonlinux.Niti.Dev-symbolic.svg/data\/icons\/org.plafonlinux.Niti.Dev-symbolic.svg/" \
		-i "core/meson.build" || die

	sed -e "/'--output'\, '@OUTPUT@'\,/a '--includedir'\, join_paths(meson.current_build_dir()\, '../api')," -i "modules-calendar/meson.build" || die

	# Fix redefining stdout macros
	sed -e "s/\bstdout\b/stdout_str/g" -i widgets-power/src/plugin.vala || die

	# Fix systemd service path
	use systemd && ( sed -e 's/%h\/\.local/\/usr/' -i data/niti-vala.service || die )

	use !elibc_glibc && eapply "${FILESDIR}/niti-vala-0.1-remove-musl-malloc_trim-function.patch"
	use !systemd && eapply "${FILESDIR}/niti-vala-0.1-enable-elogind-support.patch"
	popd
}

src_configure() {
	local emesonargs=(
		-Db_lto=$(usex lto true false)
		-Db_pgo=$(usex pgo generate off)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	insinto /usr/share/dbus-1/services
	dodir /usr/share/dbus-1/services || die
	doins subprojects/data/niti-portal.service || die
	use systemd && systemd_douserunit subprojects/data/niti-vala.service
}

pkg_postinst() {
	elog "This package uses dart-sass for compiling styles from *.scss files."
	elog "You can install dart-sass with npm: \`sudo npm install -g sass\`"
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
