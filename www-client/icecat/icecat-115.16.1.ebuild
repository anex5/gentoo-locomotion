# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Using Gentoos firefox patches as system libraries and lto are quite nice
FIREFOX_PATCHSET="firefox-${PV%%.*}esr-patches-13.tar.xz"

LLVM_COMPAT=( 18 19 )
PP="1"
PYTHON_COMPAT=( python3_{10..13} )
PYTHON_REQ_USE="ncurses,sqlite,ssl"

WANT_AUTOCONF="2.1"

VIRTUALX_REQUIRED="manual"

MOZ_ESR=yes

inherit autotools check-reqs desktop flag-o-matic gnome2-utils linux-info llvm-r1 multiprocessing \
	 multilib-minimal rust-toolchain optfeature pax-utils python-any-r1 toolchain-funcs virtualx xdg readme.gentoo-r1

PATCH_URIS=(
	https://dev.gentoo.org/~juippis/mozilla/patchsets/${FIREFOX_PATCHSET}
)

SRC_URI="
	!buildtarball? ( icecat-${PV}-${PP}gnu1.tar.bz2 )
	${PATCH_URIS[@]}
"

DESCRIPTION="GNU IceCat Web Browser"
HOMEPAGE="https://www.gnu.org/software/gnuzilla/"


LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"

CODEC_IUSE="
-aac
+dav1d
-h264
+opus
+vpx
"
IUSE+="
${CODEC_IUSE}
alsa atk buildtarball clang cpu_flags_arm_neon cups +dbus debug ffvpx hardened hwaccel
jack -jemalloc libcanberra libnotify libproxy libsecret lld lto mold +openh264 pgo
pulseaudio sndio selinux speech +system-av1 +system-ffmpeg +system-harfbuzz
+system-icu +system-jpeg +system-libevent +system-libvpx +system-png
+system-python-libs +system-webp vaapi wayland +webrtc wifi webspeech X
"

# Firefox-only IUSE
IUSE+=" geckodriver screencast"

REQUIRED_USE="
	aac? (
		system-ffmpeg
	)
	dav1d? (
		|| (
			ffvpx
			system-ffmpeg
		)
	)
	h264? (
		system-ffmpeg
	)
	libcanberra? (
		|| (
			alsa
			pulseaudio
		)
	)
	opus? (
		|| (
			ffvpx
			system-ffmpeg
		)
	)
	vpx? (
		|| (
			ffvpx
			system-ffmpeg
		)
	)
	wifi? (
		dbus
	)
	|| (
		alsa
		pulseaudio
	)
	|| (
		lld
		mold
	)
	|| (
		wayland
		X
	)
	debug? (
		!system-av1
	)
	wayland? (
		dbus
	)
"

# Firefox-only REQUIRED_USE flags
REQUIRED_USE+=" screencast? ( wayland )"

DBUS_PV="0.60"
DBUS_GLIB_PV="0.60"
FFMPEG_PV="4.4.1" # This corresponds to y in x.y.z from the subslot.
GTK3_PV="3.14.5"
NASM_PV="2.14.02"
SPEECH_DISPATCHER_PV="0.11.4-r1"
XKBCOMMON_PV="0.4.1"

FF_ONLY_DEPEND="
	screencast? (
		>=media-video/pipewire-0.3.52:=[${MULTILIB_USEDEP}]
	)
	selinux? (
		sec-policy/selinux-mozilla
	)
"
GAMEPAD_BDEPEND="
	kernel_linux? (
		sys-kernel/linux-headers
	)
"

# Same as virtual/udev-217-r5 but with multilib changes.
# Required for gamepad, or WebAuthn roaming authenticators (e.g. USB security key)
UDEV_RDEPEND="
	kernel_linux? (
		|| (
			>=sys-apps/systemd-217[${MULTILIB_USEDEP}]
			>=sys-fs/eudev-2.1.1[${MULTILIB_USEDEP}]
			sys-apps/systemd-utils[${MULTILIB_USEDEP},udev]
			sys-fs/udev[${MULTILIB_USEDEP}]
		)
	)
"
SYSTEM_PYTHON_LIBS="
	system-python-libs? (
		${PYTHON_DEPS}
		$(python_gen_any_dep '
			dev-python/zstandard[${PYTHON_USEDEP}]
			dev-python/aiohttp[${PYTHON_USEDEP}]
			dev-python/appdirs[${PYTHON_USEDEP}]
			dev-python/attrs[${PYTHON_USEDEP}]
			dev-python/cbor2[${PYTHON_USEDEP}]
			dev-python/certifi[${PYTHON_USEDEP}]
			dev-python/chardet[${PYTHON_USEDEP}]
			dev-python/click[${PYTHON_USEDEP}]
			dev-python/colorama[${PYTHON_USEDEP}]
			dev-python/cookies[${PYTHON_USEDEP}]
			dev-python/diskcache[${PYTHON_USEDEP}]
			dev-python/distro[${PYTHON_USEDEP}]
			dev-python/ecdsa[${PYTHON_USEDEP}]
			dev-python/idna[${PYTHON_USEDEP}]
			dev-python/importlib-metadata[${PYTHON_USEDEP}]
			dev-python/iso8601[${PYTHON_USEDEP}]
			dev-python/jinja[${PYTHON_USEDEP}]
			dev-python/jsmin[${PYTHON_USEDEP}]
			dev-python/jsonschema[${PYTHON_USEDEP}]
			dev-python/packaging[${PYTHON_USEDEP}]
			dev-python/pathspec[${PYTHON_USEDEP}]
			dev-python/pip[${PYTHON_USEDEP}]
			dev-python/ply[${PYTHON_USEDEP}]
			dev-python/pyasn1[${PYTHON_USEDEP}]
			dev-python/pylru[${PYTHON_USEDEP}]
			dev-python/pyparsing[${PYTHON_USEDEP}]
			dev-python/requests[${PYTHON_USEDEP}]
			dev-python/responses[${PYTHON_USEDEP}]
			dev-python/rsa[${PYTHON_USEDEP}]
			dev-python/setuptools[${PYTHON_USEDEP}]
			dev-python/six[${PYTHON_USEDEP}]
			dev-python/tomli[${PYTHON_USEDEP}]
			dev-python/tqdm[${PYTHON_USEDEP}]
			dev-python/typing-extensions[${PYTHON_USEDEP}]
			dev-python/urllib3[${PYTHON_USEDEP}]
			dev-python/voluptuous[${PYTHON_USEDEP}]
			dev-python/wcwidth[${PYTHON_USEDEP}]
			dev-python/wheel[${PYTHON_USEDEP}]
			dev-python/yarl[${PYTHON_USEDEP}]
			dev-python/zipp[${PYTHON_USEDEP}]
		')
	)
"
CDEPEND="
	${FF_ONLY_DEPEND}
	${SYSTEM_PYTHON_LIBS}
	>=app-accessibility/at-spi2-core-2.46.0:2[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.42:2[${MULTILIB_USEDEP}]
	>=dev-libs/nss-3.90.0[${MULTILIB_USEDEP}]
	>=dev-libs/nspr-4.35[${MULTILIB_USEDEP}]
	>=media-libs/fontconfig-2.7.0[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.13.0[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.13[${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.22.0[${MULTILIB_USEDEP}]
	>=x11-libs/pixman-0.36.0[${MULTILIB_USEDEP}]
	dev-libs/expat[${MULTILIB_USEDEP}]
	dev-libs/libffi:=[${MULTILIB_USEDEP}]
	media-libs/alsa-lib[${MULTILIB_USEDEP}]
	virtual/freedesktop-icon-theme
	x11-libs/cairo
	x11-libs/gdk-pixbuf[${MULTILIB_USEDEP}]
	dbus? (
		>=dev-libs/dbus-glib-${DBUS_GLIB_PV}[${MULTILIB_USEDEP}]
		>=sys-apps/dbus-${DBUS_PV}[${MULTILIB_USEDEP}]
	)
	jack? (
		virtual/jack[${MULTILIB_USEDEP}]
	)
	libproxy? (
		net-libs/libproxy[${MULTILIB_USEDEP}]
	)
	pulseaudio? (
		|| (
			media-libs/libpulse[${MULTILIB_USEDEP}]
			>=media-sound/apulse-0.1.12-r4[${MULTILIB_USEDEP},sdk]
		)
	)
	screencast? (
		media-video/pipewire:=
	)
	selinux? (
		sec-policy/selinux-mozilla
	)
	sndio? (
		>=media-sound/sndio-1.8.0-r1[${MULTILIB_USEDEP}]
	)
	system-av1? (
		>=media-libs/dav1d-1.1.0:=[${MULTILIB_USEDEP},8bit]
		>=media-libs/libaom-1.0.0:=[${MULTILIB_USEDEP}]
	)
	system-harfbuzz? (
		>=media-gfx/graphite2-1.3.14[${MULTILIB_USEDEP}]
		>=media-libs/harfbuzz-7.3.0:0=[${MULTILIB_USEDEP}]
	)
	system-icu? (
		>=dev-libs/icu-73.1:=[${MULTILIB_USEDEP}]
	)
	system-jpeg? (
		>=media-libs/libjpeg-turbo-2.1.5.1[${MULTILIB_USEDEP}]
	)
	system-ffmpeg? (
		>=media-video/ffmpeg-${FFMPEG_PV}[${MULTILIB_USEDEP},dav1d?,openh264?,opus?,vaapi?,vpx?]
	)
	system-libevent? (
		>=dev-libs/libevent-2.1.12:=[${MULTILIB_USEDEP},threads(+)]
	)
	system-libvpx? (
		>=media-libs/libvpx-1.13.0:=[${MULTILIB_USEDEP},postproc]
	)
	system-png? (
		>=media-libs/libpng-1.6.39:=[${MULTILIB_USEDEP},apng]
	)
	system-webp? (
		>=media-libs/libwebp-1.3.0:=[${MULTILIB_USEDEP}]
	)
	wayland? (
		>=media-libs/libepoxy-1.5.10-r1
		>=x11-libs/gtk+-${GTK3_PV}:3[${MULTILIB_USEDEP},wayland]
		>=x11-libs/libxkbcommon-${XKBCOMMON_PV}[${MULTILIB_USEDEP},wayland]
	)
	wifi? (
		kernel_linux? (
			>=dev-libs/dbus-glib-${DBUS_GLIB_PV}[${MULTILIB_USEDEP}]
			>=net-misc/networkmanager-0.7[${MULTILIB_USEDEP}]
			>=sys-apps/dbus-${DBUS_PV}[${MULTILIB_USEDEP}]
		)
	)
	X? (
		>=x11-libs/gtk+-${GTK3_PV}:3[${MULTILIB_USEDEP},X]
		>=x11-libs/libxkbcommon-${XKBCOMMON_PV}[${MULTILIB_USEDEP},X]
		>=x11-libs/libXrandr-1.4.0[${MULTILIB_USEDEP}]
		>=x11-libs/libXtst-1.2.3[${MULTILIB_USEDEP}]
		virtual/opengl[${MULTILIB_USEDEP}]
		x11-libs/cairo[${MULTILIB_USEDEP},X]
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXcomposite[${MULTILIB_USEDEP}]
		x11-libs/libXdamage[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		x11-libs/libXfixes[${MULTILIB_USEDEP}]
		x11-libs/libxcb:=[${MULTILIB_USEDEP}]
	)
"

# See also PR_LoadLibrary
# speech-dispatcher-0.11.3 is bugged.
RDEPEND+="
	${CDEPEND}
	${UDEV_RDEPEND}
	cups? (
		net-print/cups[${MULTILIB_USEDEP}]
	)
	jack? (
		virtual/jack[${MULTILIB_USEDEP}]
	)
	libcanberra? (
		!pulseaudio? (
			alsa? (
				media-libs/libcanberra[${MULTILIB_USEDEP},alsa]
			)
		)
		pulseaudio? (
			media-libs/libcanberra[${MULTILIB_USEDEP},pulseaudio]
		)
	)
	libnotify? (
		x11-libs/libnotify
	)
	libsecret? (
		app-crypt/libsecret[${MULTILIB_USEDEP}]
	)
	openh264? (
		media-libs/openh264:*[${MULTILIB_USEDEP},plugin]
	)
	pulseaudio? (
		|| (
			media-sound/pulseaudio[${MULTILIB_USEDEP}]
			>=media-sound/apulse-0.1.12-r4[${MULTILIB_USEDEP}]
		)
	)
	speech? (
		!pulseaudio? (
			alsa? (
				|| (
					>=app-accessibility/speech-dispatcher-${SPEECH_DISPATCHER_PV}[alsa,espeak]
					>=app-accessibility/speech-dispatcher-${SPEECH_DISPATCHER_PV}[alsa,espeak]
					>=app-accessibility/speech-dispatcher-${SPEECH_DISPATCHER_PV}[alsa,flite]
				)
			)
		)
		pulseaudio? (
			|| (
				>=app-accessibility/speech-dispatcher-${SPEECH_DISPATCHER_PV}[espeak,pulseaudio]
				>=app-accessibility/speech-dispatcher-${SPEECH_DISPATCHER_PV}[espeak,pulseaudio]
				>=app-accessibility/speech-dispatcher-${SPEECH_DISPATCHER_PV}[flite,pulseaudio]
			)
		)
	)
	vaapi? (
		media-libs/libva[${MULTILIB_USEDEP},drm(+),X?,wayland?]
	)
"
DEPEND+="
	${CDEPEND}
	pulseaudio? (
		|| (
			>=media-sound/apulse-0.1.12-r4[${MULTILIB_USEDEP},sdk]
			media-sound/pulseaudio[${MULTILIB_USEDEP}]
		)
	)
	X? (
		x11-base/xorg-proto
		x11-libs/libICE[${MULTILIB_USEDEP}]
		x11-libs/libSM[${MULTILIB_USEDEP}]
	)
"

BDEPEND+="
	${PYTHON_DEPS}
	${GAMEPAD_BDEPEND}
	>=dev-lang/perl-5.006
	>=dev-util/cbindgen-0.24.3
	>=dev-util/pkgconf-1.8.0[${MULTILIB_USEDEP},pkg-config(+)]
	>=net-libs/nodejs-12
	>=virtual/rust-1.69.0[${MULTILIB_USEDEP}]
	<virtual/rust-1.83.0[${MULTILIB_USEDEP}]
	app-alternatives/awk
	app-arch/unzip
	app-arch/zip
	buildtarball? (
		~www-client/makeicecat-"${PV}"[buildtarball]
	)
	mold? (
		sys-devel/mold
	)
	lld? (
		sys-devel/lld
	)
	amd64? ( >=dev-lang/nasm-${NASM_PV} )
	x86? ( >=dev-lang/nasm-${NASM_PV} )
	pgo? (
		X? (
			sys-devel/gettext
			x11-base/xorg-server[xvfb]
			x11-apps/xhost
		)
		wayland? (
			|| (
				gui-wm/tinywl
				<gui-libs/wlroots-0.17.3[tinywl(-)]
			)
			x11-misc/xkeyboard-config
		)
	)
	x86? (
		>=dev-lang/nasm-${NASM_PV}
	)
"

RESTRICT="mirror"

S="${WORKDIR}/${PN}-${PV%_*}"

llvm_check_deps() {
	if ! has_version -b "sys-devel/clang:${LLVM_SLOT}" ; then
		einfo "sys-devel/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang && ! use mold ; then
		if ! has_version -b "sys-devel/lld:${LLVM_SLOT}" ; then
			einfo "sys-devel/lld:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if ! has_version -b "virtual/rust:0/llvm-${LLVM_SLOT}" ; then
			einfo "virtual/rust:0/llvm-${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if use pgo ; then
			if ! has_version -b "=sys-libs/compiler-rt-sanitizers-${LLVM_SLOT}*[profile]" ; then
				einfo "=sys-libs/compiler-rt-sanitizers-${LLVM_SLOT}*[profile] is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
				return 1
			fi
		fi
	fi

	einfo "Using LLVM slot ${LLVM_SLOT} to build" >&2
}

MOZ_LANGS=(
	af ar ast be bg br ca cak cs cy da de dsb
	el en-CA en-GB en-US es-AR es-ES et eu
	fi fr fy-NL ga-IE gd gl he hr hsb hu
	id is it ja ka kab kk ko lt lv ms nb-NO nl nn-NO
	pa-IN pl pt-BR pt-PT rm ro ru
	sk sl sq sr sv-SE th tr uk uz vi zh-CN zh-TW
)

# Firefox-only LANGS
MOZ_LANGS+=( ach )
MOZ_LANGS+=( an )
MOZ_LANGS+=( az )
MOZ_LANGS+=( bn )
MOZ_LANGS+=( bs )
MOZ_LANGS+=( ca-valencia )
MOZ_LANGS+=( eo )
MOZ_LANGS+=( es-CL )
MOZ_LANGS+=( es-MX )
MOZ_LANGS+=( fa )
MOZ_LANGS+=( ff )
MOZ_LANGS+=( fur )
MOZ_LANGS+=( gn )
MOZ_LANGS+=( gu-IN )
MOZ_LANGS+=( hi-IN )
MOZ_LANGS+=( hy-AM )
MOZ_LANGS+=( ia )
MOZ_LANGS+=( km )
MOZ_LANGS+=( kn )
MOZ_LANGS+=( lij )
MOZ_LANGS+=( mk )
MOZ_LANGS+=( mr )
MOZ_LANGS+=( my )
MOZ_LANGS+=( ne-NP )
MOZ_LANGS+=( oc )
MOZ_LANGS+=( sc )
MOZ_LANGS+=( sco )
MOZ_LANGS+=( si )
MOZ_LANGS+=( son )
MOZ_LANGS+=( szl )
MOZ_LANGS+=( ta )
MOZ_LANGS+=( te )
MOZ_LANGS+=( tl )
MOZ_LANGS+=( trs )
MOZ_LANGS+=( ur )
MOZ_LANGS+=( xh )

mozilla_set_globals() {
	# https://bugs.gentoo.org/587334
	local MOZ_TOO_REGIONALIZED_FOR_L10N=(
		fy-NL ga-IE gu-IN hi-IN hy-AM nb-NO ne-NP nn-NO pa-IN sv-SE
	)

	local lang xflag
	for lang in "${MOZ_LANGS[@]}" ; do
		# en and en_US are handled internally
		if [[ ${lang} == en ]] || [[ ${lang} == en-US ]] ; then
			continue
		fi

		# strip region subtag if $lang is in the list
		if has ${lang} "${MOZ_TOO_REGIONALIZED_FOR_L10N[@]}" ; then
			xflag=${lang%%-*}
		else
			xflag=${lang}
		fi

		IUSE+=" l10n_${xflag/[_@]/-}"
	done
}
mozilla_set_globals

moz_clear_vendor_checksums() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -ne 1 ]] ; then
		die "${FUNCNAME} requires exact one argument"
	fi

	einfo "Clearing cargo checksums for ${1} ..."

	sed -i \
		-e 's/\("files":{\)[^}]*/\1/' \
		"${S}"/third_party/rust/${1}/.cargo-checksum.json \
		|| die
}

moz_build_xpi() {
	debug-print-function ${FUNCNAME} "$@"

	local MOZ_TOO_REGIONALIZED_FOR_L10N=(
		fy-NL ga-IE gu-IN hi-IN hy-AM nb-NO ne-NP nn-NO pa-IN sv-SE
	)

	cd "${BUILD_OBJ_DIR}"/browser/locales || die
	local lang xflag
	for lang in "${MOZ_LANGS[@]}"; do
		# en and en_US are handled internally
		if [[ ${lang} == en ]] || [[ ${lang} == en-US ]] ; then
			continue
		fi

		# strip region subtag if $lang is in the list
		if has ${lang} "${MOZ_TOO_REGIONALIZED_FOR_L10N[@]}" ; then
			xflag=${lang%%-*}
		else
			xflag=${lang}
		fi

		if use l10n_"${xflag}"; then
			emake langpack-"${lang}" LOCALE_MERGEDIR=.
		fi
	done
}

moz_install_xpi() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local DESTDIR=${1}
	shift

	insinto "${DESTDIR}"

	local emid xpi_file xpi_tmp_dir
	for xpi_file in "${@}" ; do
		emid=
		xpi_tmp_dir=$(mktemp -d --tmpdir="${T}")

		# Unpack XPI
		unzip -qq "${xpi_file}" -d "${xpi_tmp_dir}" || die

		# Determine extension ID
		if [[ -f "${xpi_tmp_dir}/install.rdf" ]] ; then
			emid=$(sed -n -e '/install-manifest/,$ { /em:id/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }' "${xpi_tmp_dir}/install.rdf")
			[[ -z "${emid}" ]] && die "failed to determine extension id from install.rdf"
		elif [[ -f "${xpi_tmp_dir}/manifest.json" ]] ; then
			emid=$(sed -n -e 's/.*"id": "\([^"]*\)".*/\1/p' "${xpi_tmp_dir}/manifest.json")
			[[ -z "${emid}" ]] && die "failed to determine extension id from manifest.json"
		else
			die "failed to determine extension id"
		fi

		einfo "Installing ${emid}.xpi into ${ED}${DESTDIR} ..."
		newins "${xpi_file}" "${emid}.xpi"
	done
}

mozconfig_add_options_ac() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "ac_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_add_options_mk() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "mk_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_use_enable() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_enable "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

mozconfig_use_with() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_with "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}



virtwl() {
	debug-print-function ${FUNCNAME} "$@"

	[[ $# -lt 1 ]] && die "${FUNCNAME} needs at least one argument"
	[[ -n $XDG_RUNTIME_DIR ]] || die "${FUNCNAME} needs XDG_RUNTIME_DIR to be set; try xdg_environment_reset"
	tinywl -h >/dev/null || die 'tinywl -h failed'

	# TODO: don't run addpredict in utility function. WLR_RENDERER=pixman doesn't work
	addpredict "/dev/dri"
	local VIRTWL VIRTWL_PID
	coproc VIRTWL { WLR_BACKENDS=headless exec tinywl -s 'echo $WAYLAND_DISPLAY; read _; kill $PPID'; }
	local -x WAYLAND_DISPLAY
	read WAYLAND_DISPLAY <&${VIRTWL[0]}

	debug-print "${FUNCNAME}: $@"
	"$@"
	local r=$?

	[[ -n $VIRTWL_PID ]] || die "tinywl exited unexpectedly"
	exec {VIRTWL[0]}<&- {VIRTWL[1]}>&-
	return $r
}

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]] ; then
		if use pgo ; then
			if ! has usersandbox $FEATURES ; then
				die "You must enable usersandbox as X server can not run as root!"
			fi
		fi

		# Ensure we have enough disk space to compile
		if use pgo || use lto || use debug ; then
			CHECKREQS_DISK_BUILD="13500M"
		else
			CHECKREQS_DISK_BUILD="6600M"
		fi

		check-reqs_pkg_pretend
	fi
}

pkg_nofetch() {
	if ! use buildtarball; then
		einfo "You have not enabled buildtarball use flag, therefore you will have to"
		einfo "build the tarball manually and place it in your distfiles directory."
		einfo "You may find the script for building the tarball here"
		einfo "https://git.savannah.gnu.org/cgit/gnuzilla.git/, but make sure it is the"
		einfo "right version."
		einfo "The output of the script should be icecat-${PV}-${PP}gnu1.tar.bz2"
	fi
}

#NABIS=0
pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]] ; then
		if use pgo ; then
			if ! has userpriv ${FEATURES} ; then
				eerror "Building ${PN} with USE=pgo and FEATURES=-userpriv is not supported!"
			fi
		fi

		# Ensure we have enough disk space to compile
		if use pgo || use lto || use debug ; then
			CHECKREQS_DISK_BUILD="13500M"
		else
			CHECKREQS_DISK_BUILD="6400M"
		fi

		check-reqs_pkg_setup

		llvm-r1_pkg_setup

		if use clang && use pgo && use lld ; then
			has_version "sys-devel/lld:$(clang-major-version)" \
				|| die "Clang PGO requires LLD."
			local lld_pv=$(ld.lld --version 2>/dev/null \
				| awk '{ print $2 }')
			if [[ -n ${lld_pv} ]] ; then
				lld_pv=$(ver_cut 1 "${lld_pv}")
			fi
			if [[ -z ${lld_pv} ]] ; then
				eerror
				eerror "Failed to read ld.lld version!"
				eerror
				die
			fi

			local llvm_rust_pv=$(rustc -Vv 2>/dev/null \
				| grep -F -- 'LLVM version:' \
				| awk '{ print $3 }')
			if [[ -n ${llvm_rust_pv} ]] ; then
				llvm_rust_pv=$(ver_cut 1 "${llvm_rust_pv}")
			fi
			if [[ -z ${llvm_rust_pv} ]] ; then
				eerror
				eerror "Failed to read used LLVM version from rustc!"
				eerror
				die
			fi

			if ver_test "${lld_pv}" -lt "${llvm_rust_pv}" ; then
				eerror
				eerror "Rust is using LLVM version ${llvm_rust_pv} but ld.lld version"
				eerror "belongs to LLVM version ${lld_pv}."
				eerror
				eerror "You will be unable to link ${CATEGORY}/${PN}. To proceed you have the"
				eerror "following options:"
				eerror
				eerror "  - Manually switch rust version using 'eselect rust' to match used"
				eerror "    LLVM version"
				eerror "  - Switch to dev-lang/rust[system-llvm] which will guarantee the"
				eerror "    matching version"
				eerror "  - Build ${CATEGORY}/${PN} without USE=lto"
				eerror "  - Rebuild lld with llvm that was used to build rust (may need to"
				eerror "    rebuild the whole llvm/clang/lld/rust chain depending on your"
				eerror "    @world updates)"
				eerror
				eerror "LLVM version used by Rust (${llvm_rust_pv}) does not match with"
				eerror "ld.lld version (${lld_pv})!"
				eerror
				die
			fi
		fi

		python-any-r1_pkg_setup

		# Avoid PGO profiling problems due to enviroment leakage
		# These should *always* be cleaned up anyway
		unset \
			DBUS_SESSION_BUS_ADDRESS \
			DISPLAY \
			ORBIT_SOCKETDIR \
			SESSION_MANAGER \
			XAUTHORITY \
			XDG_CACHE_HOME \
			XDG_SESSION_COOKIE

		# Build system is using /proc/self/oom_score_adj, bug #604394
		addpredict /proc/self/oom_score_adj

		if use pgo ; then
			# Update 105.0: "/proc/self/oom_score_adj" isn't enough anymore with pgo, but not sure
			# whether that's due to better OOM handling by Firefox (bmo#1771712), or portage
			# (PORTAGE_SCHEDULING_POLICY) update...
			addpredict "/proc"

			# Clear tons of conditions, since PGO is hardware-dependant.
			addpredict "/dev"

			# Allow access to GPU during PGO run
			local ati_cards mesa_cards nvidia_cards render_cards
			shopt -s nullglob

			ati_cards=$(echo -n /dev/ati/card* | sed 's/ /:/g')
			if [[ -n "${ati_cards}" ]] ; then
				addpredict "${ati_cards}"
			fi

			mesa_cards=$(echo -n /dev/dri/card* | sed 's/ /:/g')
			if [[ -n "${mesa_cards}" ]] ; then
				addpredict "${mesa_cards}"
			fi

			nvidia_cards=$(echo -n /dev/nvidia* | sed 's/ /:/g')
			if [[ -n "${nvidia_cards}" ]] ; then
				addpredict "${nvidia_cards}"
			fi

			render_cards=$(echo -n /dev/dri/renderD128* | sed 's/ /:/g')
			if [[ -n "${render_cards}" ]] ; then
				addpredict "${render_cards}"
			fi

			shopt -u nullglob
		fi

		if ! mountpoint -q /dev/shm ; then
			# If /dev/shm is not available, configure is known to fail with
			# a traceback report referencing /usr/lib/pythonN.N/multiprocessing/synchronize.py
			ewarn "/dev/shm is not mounted -- expect build failures!"
		fi

		# Google API keys (see http://www.chromium.org/developers/how-tos/api-keys)
		# Note: These are for Gentoo Linux use ONLY. For your own distribution, please
		# get your own set of keys.
		if [[ -z "${MOZ_API_KEY_GOOGLE+set}" ]] ; then
			MOZ_API_KEY_GOOGLE="AIzaSyDEAOvatFogGaPi0eTgsV_ZlEzx0ObmepsMzfAc"
		fi

		if [[ -z "${MOZ_API_KEY_LOCATION+set}" ]] ; then
			MOZ_API_KEY_LOCATION="AIzaSyB2h2OuRgGaPicUgy5N-5hsZqiPW6sH3n_rptiQ"
		fi

		# Mozilla API keys (see https://location.services.mozilla.com/api)
		# Note: These are for Gentoo Linux use ONLY. For your own distribution, please
		# get your own set of keys.
		if [[ -z "${MOZ_API_KEY_MOZILLA+set}" ]] ; then
			MOZ_API_KEY_MOZILLA="edb3d487-3a84-46m0ap1e3-9dfd-92b5efaaa005"
		fi

		# Ensure we use C locale when building, bug #746215
		export LC_ALL=C
	fi

	linux-info_pkg_setup

	if ! use pulseaudio ; then
		ewarn
		ewarn "Microphone support may be disabled when USE=-pulseaudio."
		ewarn
	fi

	local a
	for a in $(multilib_get_enabled_abis) ; do
		NABIS=$((${NABIS} + 1))
	done

	if [[ "${RUSTC_WRAPPER}" =~ "sccache" ]] ; then
		ewarn
		ewarn "Using sccache may randomly fail.  Retry if it fails."
		ewarn
	fi

	if ! use wayland ; then
		ewarn
		ewarn "Disabling the wayland USE flag has the following consequences:"
		ewarn
		ewarn "  (1) Degrade WebGL FPS by less than 25 FPS (15 FPS on average)"
		ewarn "  (2) Always use software CPU based video decode for VP8, VP9, AV1."
		ewarn "      If the wayland USE flag is enabled, it will use GPU accelerated"
		ewarn "      decoding if supported."
		ewarn
	fi
	if use webspeech ; then
		ewarn
		ewarn "Speech recognition (USE=webspeech) has not been confirmed working."
		ewarn
	fi
}

src_unpack() {
	if use buildtarball; then
		unpack "/usr/src/makeicecat-${PV}/output/icecat-${PV}-${PP}gnu1.tar.bz2" || eerror "Tarball is missing, check that www-client/makeicecat has use flag buildtarball enabled."
	else
		unpack "icecat-${PV}-${PP}gnu1.tar.bz2"
	fi
	unpack "${FIREFOX_PATCHSET}"
}

_get_s() {
	if (( ${NABIS} == 1 )) ; then
		echo "${S}"
	else
		echo "${S}-${MULTILIB_ABI_FLAG}.${ABI}"
	fi
}

src_prepare() {
	use elibc_musl && eapply "${FILESDIR}/icecat-musl-sandbox.patch"
	use atk || eapply "${FILESDIR}/icecat-no-atk.patch"
	use dbus || eapply "${FILESDIR}/icecat-no-dbus.patch"
	eapply "${FILESDIR}/icecat-no-fribidi.patch"
	eapply "${FILESDIR}/icecat-fix-clang-as.patch"
	eapply "${FILESDIR}/icecat-system-gtests.patch"

	if use lto; then
		rm -v "${WORKDIR}"/firefox-patches/*-LTO-Only-enable-LTO-*.patch || die
	fi

	if ! use ppc64; then
		rm -v "${WORKDIR}"/firefox-patches/*ppc64*.patch || die
	fi

	if use x86 && use elibc_glibc ; then
		rm -v "${WORKDIR}"/firefox-patches/*-musl-non-lfs64-api-on-audio_thread_priority-crate.patch || die
	fi

	eapply "${FILESDIR}/extra-patches/firefox-106.0.2-disallow-store-data-races.patch"

	# Flicker prevention with -Ofast
	eapply "${FILESDIR}/extra-patches/firefox-106.0.2-disable-broken-flags-gfx-layers.patch"

	# Prevent YT stall prevention with clang with -Ofast.
	# Prevent audio perma mute with gcc with -Ofast.
	eapply "${FILESDIR}/extra-patches/firefox-106.0.2-disable-broken-flags-js.patch"

	# Only partial patching was done because the distro doesn't support
	# multilib Python.  Only native ABI is supported.  This means cbindgen
	# cannot load the 32-bit clang.  It will build the cargo parts.  When it
	# links it, it fails because of cbindings is 64-bit and the dependencies
	# use the build information for 64-bit linking, which should be 32-bit.

	#eapply "${DISTDIR}/${PN}-d4f5769.patch"

	# Allow to use system-ffmpeg completely.
	eapply "${FILESDIR}/extra-patches/firefox-115e-allow-ffmpeg-decode-av1.patch"
	eapply "${FILESDIR}/extra-patches/firefox-115e-disable-ffvpx.patch"

	# Prevent tab crash
	eapply "${FILESDIR}/extra-patches/firefox-106.0.2-disable-broken-flags-dom-bindings.patch"

	# Prevent video seek bug
	eapply "${FILESDIR}/extra-patches/firefox-106.0.2-disable-broken-flags-ipc-chromium-chromium-config.patch"

	# Workaround for bgo#917599
	if has_version ">=dev-libs/icu-74.1" && use system-icu ; then
		eapply "${WORKDIR}/firefox-patches/0029-bmo-1862601-system-icu-74.patch"
	fi

	rm -v "${WORKDIR}/firefox-patches/0029-bmo-1862601-system-icu-74.patch" || die

	# Workaround for bgo#915651 on musl
	if use elibc_glibc ; then
		rm -v "${WORKDIR}/firefox-patches/"*"bgo-748849-RUST_TARGET_override.patch" || die
	fi

	# Modify patch to apply correctly
	sed -i -e 's/firefox/icecat/' "${WORKDIR}"/firefox-patches/0033-bmo-1882209-update-crates-for-rust-1.78-stripped-patch-from-bugs.freebsd.org-bug278834.patch || die
	# sed -i -e 's/880c982df0843cbdff38b9f9c3829a2d863a224e4de2260c41c3ac69e9148ad4/239b3e4d20498f69ed5f94481ed932340bd58cb485b26c35b09517f249d20d11/' "${S}"/third_party/rust/bindgen/.cargo-checksum.json || die

	eapply "${WORKDIR}/firefox-patches"

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	# Make cargo respect MAKEOPTS
	[[ -n ${CARGO_BUILD_JOBS} ]] || export CARGO_BUILD_JOBS="$(makeopts_jobs)"
	# Workaround for bgo#915651
	if ! use elibc_glibc ; then
		if use amd64 ; then
			export RUST_TARGET="x86_64-unknown-linux-musl"
		elif use x86 ; then
			export RUST_TARGET="i686-unknown-linux-musl"
		elif use arm64 ; then
			export RUST_TARGET="aarch64-unknown-linux-musl"
		else
			eerror
			eerror "Unknown musl chost, please post your rustc -vV along with"
			eerror "\`emerge --info\` on Gentoo's bug #915651"
			eerror
			die
		fi
	fi


	# Make LTO & ICU respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}/build/moz.configure/lto-pgo.configure" \
		"${S}/intl/icu_sources_data.py" \
		|| die "sed failed to set num_cores"

	# sed-in toolchain prefix
	sed -i \
		-e "s/objdump/${CHOST}-objdump/" \
		"${S}"/python/mozbuild/mozbuild/configure/check_debug_ranges.py \
		|| die "sed failed to set toolchain prefix"

	sed -i \
		-e 's/ccache_stats = None/return None/' \
		"${S}"/python/mozbuild/mozbuild/controller/building.py \
		|| die "sed failed to disable ccache stats call"

	einfo "Removing pre-built binaries ..."

	find "${S}"/third_party -type f \( -name '*.so' -o -name '*.o' \) -print -delete || die

	# Clear cargo checksums from crates we have patched
	# moz_clear_vendor_checksums crate
	moz_clear_vendor_checksums audio_thread_priority
	moz_clear_vendor_checksums bindgen
	moz_clear_vendor_checksums encoding_rs
	moz_clear_vendor_checksums any_all_workaround
	moz_clear_vendor_checksums packed_simd

	# Write API keys to disk
	echo -n "${MOZ_API_KEY_GOOGLE//gGaPi/}" > "${S}"/api-google.key || die
	echo -n "${MOZ_API_KEY_LOCATION//gGaPi/}" > "${S}"/api-location.key || die
	echo -n "${MOZ_API_KEY_MOZILLA//m0ap1/}" > "${S}"/api-mozilla.key || die

	xdg_environment_reset

	(( ${NABIS} > 1 )) && multilib_copy_sources

	_src_prepare() {
		cd $(_get_s) || die
		local CDEFAULT=$(get_abi_CHOST ${DEFAULT_ABI})
		# Only ${CDEFAULT}-objdump exists because in true multilib.
		# Logically speaking, there should be i686-pc-linux-gnu-objdump also.
		if [[ -e "${ESYSROOT}/usr/bin/${CHOST}-objdump" ]] ; then
		# Adds the toolchain prefix.
			sed -i \
				-e "s/\"objdump/\"${CHOST}-objdump/" \
				python/mozbuild/mozbuild/configure/check_debug_ranges.py \
				|| die "sed failed to set toolchain prefix"
			einfo "Using ${CHOST}-objdump for CHOST"
		else
			[[ -e "${ESYSROOT}/usr/bin/${CDEFAULT}-objdump" ]] || die
			# Adds the toolchain prefix.
			sed -i \
				-e "s/\"objdump/\"${CDEFAULT}-objdump/" \
				python/mozbuild/mozbuild/configure/check_debug_ranges.py \
				|| die "sed failed to set toolchain prefix"
			ewarn "Using ${CDEFAULT}-objdump for CDEFAULT"
		fi
	}
}

# Corrections based on the ABI being compiled
# Preconditions:
#   CHOST must be defined
#   cwd is ABI's S
_fix_paths() {
	# For proper rust cargo cross-compile for libloading and glslopt
	export PKG_CONFIG="${CHOST}-pkg-config"
	export CARGO_CFG_TARGET_ARCH=$(echo "${CHOST}" \
		| cut -f 1 -d "-")
	export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	export BUILD_OBJ_DIR="$(pwd)/ff"

	# Set MOZCONFIG
	export MOZCONFIG="$(pwd)/.mozconfig"

	# For rust crates libloading and glslopt
	if tc-is-clang ; then
		local version_clang=$(clang --version 2>/dev/null \
			| grep -F -- 'clang version' \
			| awk '{ print $3 }')
		if [[ -n ${version_clang} ]] ; then
			version_clang=$(ver_cut 1 "${version_clang}")
		else
			eerror
			eerror "Failed to read clang version!"
			eerror
			die
		fi
		CC="${CHOST}-clang-${version_clang}"
		CXX="${CHOST}-clang++-${version_clang}"
	else
		CC="${CHOST}-gcc"
		CXX="${CHOST}-g++"
	fi
	tc-export CC CXX
	strip-unsupported-flags
}

append_all() {
	append-flags ${@}
	append-ldflags ${@}
}

is_flagq_last() {
	local flag="${1}"
	local olast=$(echo "${CFLAGS}" \
		| grep -o -E -e "-O(0|g|1|z|s|2|3|4|fast)" \
		| tr " " "\n" \
		| tail -n 1)
einfo "CFLAGS:\t${CFLAGS}"
einfo "olast:\t${olast}"
	[[ "${flag}" == "${olast}" ]] && return 0
	return 1
}

get_olast() {
	local olast=$(echo "${CFLAGS}" \
		| grep -o -E -e "-O(0|g|1|z|s|2|3|4|fast)" \
		| tr " " "\n" \
		| tail -n 1)
	if [[ -n "${olast}" ]] ; then
		echo "${olast}"
	else
		# Upstream default
		echo "-O3"
	fi
}

check_speech_dispatcher() {
	if use speech ; then
		if [[ ! -f "${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ]] ; then
			eerror
			eerror "Missing ${ESYSROOT}/etc/speech-dispatcher/speechd.conf"
			eerror
			die
		fi
		if has_version "app-accessibility/speech-dispatcher[pulseaudio]" ; then
			if ! grep -q -e "^AudioOutputMethod.*\"pulse\"" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf"
				eerror
				eerror "AudioOutputMethod \"pulse\""
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
		elif has_version "app-accessibility/speech-dispatcher[alsa]" ; then
			if ! grep -q -e "^AudioOutputMethod.*\"alsa\"" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf:"
				eerror
				eerror "AudioOutputMethod \"alsa\""
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
		fi
		if has_version "app-accessibility/speech-dispatcher[espeak]" ; then
			if ! grep -q -e "^AddModule.*\"espeak-ng\"" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf:"
				eerror
				eerror "AddModule \"espeak-ng\"                \"sd_espeak-ng\" \"espeak-ng.conf\""
				eerror "DefaultModule espeak-ng"
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
			if ! grep -q -e "^DefaultModule.*espeak-ng" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf:"
				eerror
				eerror "DefaultModule espeak-ng"
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
		elif has_version "app-accessibility/speech-dispatcher[espeak]" ; then
			if ! grep -q -e "^AddModule.*\"espeak\"" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf:"
				eerror
				eerror "AddModule \"espeak\"                   \"sd_espeak\"    \"espeak.conf\""
				eerror "DefaultModule espeak"
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
			if ! grep -q -e "^DefaultModule.*espeak" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf:"
				eerror
				eerror "DefaultModule espeak"
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
		elif has_version "app-accessibility/speech-dispatcher[flite]" ; then
			if ! grep -q -e "^AddModule.*\"flite\"" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf:"
				eerror
				eerror "#AddModule \"flite\"                    \"sd_flite\"     \"flite.conf\""
				eerror "DefaultModule flite"
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
			if ! grep -q -e "^DefaultModule.*flite" \
				"${ESYSROOT}/etc/speech-dispatcher/speechd.conf" ; then
				eerror
				eerror "The following changes are required to"
				eerror "${ESYSROOT}/etc/speech-dispatcher/speechd.conf:"
				eerror
				eerror "DefaultModule flite"
				eerror
				eerror "The ~/.config/speech-dispatcher/speechd.conf should be removed or have"
				eerror "the same settings."
				eerror
				die
			fi
		fi
	fi
}

OFLAG=""
LTO_TYPE=""
_src_configure() {
	local s=$(_get_s)
	cd "${s}" || die

	local CDEFAULT=$(get_abi_CHOST ${DEFAULT_ABI})
	# Show flags set at the beginning
	einfo
	einfo "Current BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Current CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Current CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Current LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Current RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"
	einfo "Current CHOST:\t\t${CHOST:-no value set}"
	einfo

	local have_switched_compiler=
	if use clang ; then
	# Force clang
	einfo
	einfo "Switching to clang"
	einfo
		local version_clang=$(clang --version 2>/dev/null \
			| grep -F -- 'clang version' \
			| awk '{ print $3 }')
		if [[ -n ${version_clang} ]] ; then
			version_clang=$(ver_cut 1 "${version_clang}")
		else
			eerror
			eerror "Failed to read clang version!"
			eerror
			die
		fi
		have_switched_compiler="yes"
		AR="llvm-ar"
		AS="llvm-as"
		CC="${CHOST}-clang-${version_clang}"
		CXX="${CHOST}-clang++-${version_clang}"
		NM="llvm-nm"
		RANLIB="llvm-ranlib"
		local clang_slot=$(clang-major-version)
		if ! has_version "sys-devel/lld:${clang_slot}" ; then
			eerror
			eerror "You need to emerge sys-devel/lld:${clang_slot}"
			eerror
			die
		fi
		if ! has_version "=sys-libs/compiler-rt-sanitizers-${clang_slot}*[profile]" ; then
			eerror
			eerror "You need to emerge =sys-libs/compiler-rt-sanitizers-${clang_slot}*[profile]"
			eerror
			die
		fi
	else
	# Force gcc
	ewarn
	ewarn "GCC is not the upstream default"
	ewarn
		have_switched_compiler=yes
	einfo
	einfo "Switching to gcc"
	einfo
		AR=gcc-ar
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		NM=gcc-nm
		RANLIB=gcc-ranlib
	fi

	if [[ -n "${have_switched_compiler}" ]] ; then
		# Because we switched active compiler, we have to ensure
		# that no unsupported flags are set
		strip-unsupported-flags
	fi

	check_speech_dispatcher

	# Ensure we use correct toolchain,
	# AS is used in a non-standard way by upstream, #bmo1654031
	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	tc-export CC CXX LD AR NM OBJDUMP RANLIB PKG_CONFIG
	_fix_paths
	# Pass the correct toolchain paths through cbindgen
	if tc-is-cross-compiler ; then
		export BINDGEN_CFLAGS="
			${SYSROOT:+--sysroot=${ESYSROOT}}
			--host=${CDEFAULT}
			--target=${CHOST}
			${BINDGEN_CFLAGS-}
		"
	fi

	# Set MOZILLA_FIVE_HOME
	export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	# Set state path
	export MOZBUILD_STATE_PATH="${BUILD_OBJ_DIR}"

	# Set MOZCONFIG
	export MOZCONFIG="${s}/.mozconfig"

	# Initialize MOZCONFIG
	mozconfig_add_options_ac '' --enable-application="browser"
	mozconfig_add_options_ac '' --enable-project="browser"

	# Set Gentoo defaults
	export MOZILLA_OFFICIAL=1

	mozconfig_add_options_ac \
		'Gentoo default' \
		--allow-addon-sideload \
		--disable-cargo-incremental \
		--disable-crashreporter \
		--disable-eme \
		--disable-gpsd \
		--disable-install-strip \
		--disable-parental-controls \
		--disable-strip \
		--disable-tests \
		--disable-updater \
		--disable-wmf \
		--enable-legacy-profile-creation \
		--enable-negotiateauth \
		--enable-new-pass-manager \
		--enable-official-branding \
		--enable-release \
		--enable-system-ffi \
		--enable-system-pixman \
		--enable-system-policies \
		--host="${CDEFAULT}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--prefix="${EPREFIX}/usr" \
		--target="${CHOST}" \
		--without-ccache \
		--without-wasm-sandboxed-libraries \
		--with-intl-api \
		--with-l10n-base="${s}/l10n" \
		--with-system-nspr \
		--with-system-nss \
		--with-system-zlib \
		--with-toolchain-prefix="${CHOST}-" \
		--with-unsigned-addon-scopes="app,system" \
		--x-includes="${ESYSROOT}/usr/include" \
		--x-libraries="${ESYSROOT}/usr/$(get_libdir)"

	if use system-ffmpeg ; then
		mozconfig_add_options_ac \
			'+system-ffmpeg' \
			--enable-ffmpeg
	else
		mozconfig_add_options_ac \
			'-system-ffmpeg' \
			--disable-ffmpeg
	fi

	if use ffvpx ; then
		mozconfig_add_options_ac \
			'ffvpx=default' \
			--with-ffvpx="default"
	else
		mozconfig_add_options_ac \
			'ffvpx=no' \
			--with-ffvpx="no"
	fi

	# mozconfig_add_options_ac \
	#	'' \
	#	--with-libclang-path="$(${CHOST}-llvm-config --libdir)"
	# Disabled the lines above because the distro doesn't support multilib
	# python, so full cross-compile is not supported.

	# The commented lines above are mutually exclusive with this line below.
	mozconfig_add_options_ac \
		'' \
		--with-libclang-path="$(llvm-config --libdir)"

	# Set update channel
	mozconfig_add_options_ac '' --update-channel="esr"

	#if ! use x86 && [[ ${CHOST} != armv*h* ]] ; then
	#	mozconfig_add_options_ac '' --enable-rust-simd
	#fi

	# For future keywording: This is currently (97.0) only supported on:
	# amd64, arm, arm64, and x86.
	# You might want to flip the logic around if Firefox is to support more
	# arches.
	# bug 833001, bug 903411#c8
	if use ppc64 || use riscv ; then
		mozconfig_add_options_ac '' --disable-sandbox
	else
		mozconfig_add_options_ac '' --enable-sandbox
	fi

	# Enable JIT on riscv64 explicitly
	# Can be removed once upstream enable it by default in the future.
	use riscv && mozconfig_add_options_ac 'Enable JIT for RISC-V 64' --enable-jit

	if [[ -s "${s}/api-google.key" ]] ; then
		local key_origin="Gentoo default"
		if [[ $(cat "${s}/api-google.key" | md5sum | awk '{ print $1 }') != 709560c02f94b41f9ad2c49207be6c54 ]] ; then
			key_origin="User value"
		fi

		mozconfig_add_options_ac "${key_origin}" \
			--with-google-safebrowsing-api-keyfile="${s}/api-google.key"
	else
		einfo "Building without Google API key ..."
	fi

	if [[ -s "${s}/api-location.key" ]] ; then
		local key_origin="Gentoo default"
		if [[ $(cat "${s}/api-location.key" | md5sum | awk '{ print $1 }') != ffb7895e35dedf832eb1c5d420ac7420 ]] ; then
			key_origin="User value"
		fi

		mozconfig_add_options_ac "${key_origin}" \
			--with-google-location-service-api-keyfile="${s}/api-location.key"
	else
		einfo "Building without Location API key ..."
	fi

	if [[ -s "${s}/api-mozilla.key" ]] ; then
		local key_origin="Gentoo default"
		if [[ $(cat "${s}/api-mozilla.key" | md5sum | awk '{ print $1 }') != 3927726e9442a8e8fa0e46ccc39caa27 ]] ; then
			key_origin="User value"
		fi

		mozconfig_add_options_ac "${key_origin}" \
			--with-mozilla-api-keyfile="${s}/api-mozilla.key"
	else
		einfo "Building without Mozilla API key ..."
	fi

	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-harfbuzz system-graphite2
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libevent
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-png
	mozconfig_use_with system-webp

	mozconfig_use_enable atk accessibility
	mozconfig_use_enable dbus
	mozconfig_use_enable libproxy
	mozconfig_use_enable cups printing
	multilib_is_native_abi && mozconfig_use_enable speech synth-speechd
	mozconfig_use_enable webrtc
	mozconfig_use_enable webspeech
	mozconfig_use_enable geckodriver

	# The upstream default is hardening on even if unset.
	if use hardened ; then
		mozconfig_add_options_ac "+hardened" --enable-hardening
		append-ldflags "-Wl,-z,relro -Wl,-z,now" # Full Relro
	else
		mozconfig_add_options_ac "-hardened" --disable-hardening
	fi

	local myaudiobackends=""
	use jack && myaudiobackends+="jack,"
	use sndio && myaudiobackends+="sndio,"
	use pulseaudio && myaudiobackends+="pulseaudio,"
	! use pulseaudio && myaudiobackends+="alsa,"

	mozconfig_add_options_ac \
		'--enable-audio-backends' \
		--enable-audio-backends=$(echo "${myaudiobackends}" \
			| sed -e "s|,$||g") # Cannot be empty

	mozconfig_use_enable wifi necko-wifi

	if use X && use wayland ; then
		mozconfig_add_options_ac '+x11+wayland' --enable-default-toolkit="cairo-gtk3-x11-wayland"
	elif ! use X && use wayland ; then
		mozconfig_add_options_ac '+wayland' --enable-default-toolkit="cairo-gtk3-wayland-only"
	else
		mozconfig_add_options_ac '+x11' --enable-default-toolkit="cairo-gtk3"
	fi

	if use lto; then
		if tc-is-cross-compiler; then
			mozconfig_add_options_ac '+lto' --enable-lto="cross"
		elif use clang; then
			mozconfig_add_options_ac '+lto' --enable-lto="thin"
		else
			mozconfig_add_options_ac '+lto' --enable-lto="full"
		fi

		if use pgo ; then
			mozconfig_add_options_ac '+pgo' MOZ_PGO=1

			if use clang ; then
				# Used in build/pgo/profileserver.py
				export LLVM_PROFDATA="llvm-profdata"
				mozconfig_add_options_ac '+pgo-rust' MOZ_PGO_RUST=1
			fi
		fi
	fi
	# Avoid auto-magic on linker
	if use mold ; then
		mozconfig_add_options_ac "using ld=mold due to system selection" --enable-linker="mold"
	elif use lld ; then
		mozconfig_add_options_ac "using ld=lld due to system selection" --enable-linker="lld"
	else
		mozconfig_add_options_ac "linker is set to bfd" --enable-linker="bfd"
	fi

	# Linker flags are set from above.
	filter-ldflags '-fuse-ld=*' '-Wl,-fuse-ld=*'
	filter-flags '-fuse-ld=*' '-Wl,-fuse-ld=*'
	export RUSTFLAGS="${RUSTFLAGS/-C link-arg=-fuse-ld=lld/}"
	export RUSTFLAGS="${RUSTFLAGS/-C link-arg=-fuse-ld=mold/}"
	export RUSTFLAGS="${RUSTFLAGS/-C linker-plugin-lto/}"
	export RUSTFLAGS="${RUSTFLAGS/-C link-arg=-flto/}"

	# LTO flag was handled via configure
	filter-lto

	# Filter ldflags after linker switch
	strip-unsupported-flags

	mozconfig_use_enable debug
	if use debug ; then
		mozconfig_add_options_ac \
			'+debug' \
			--disable-optimize
		mozconfig_add_options_ac \
			'+debug' \
			--enable-real-time-tracing
	else
		mozconfig_add_options_ac \
			'Gentoo defaults' \
			--disable-real-time-tracing

		mozconfig_add_options_ac \
			'Gentoo default' \
			--disable-debug-symbols

	# Fork ebuild or set USE=debug if you want -Og
		if is_flagq_last '-Ofast' || [[ "${OFLAG}" == "-Ofast" ]] ; then
		einfo "Using -Ofast"
			OFLAG="-Ofast"
			mozconfig_add_options_ac \
				"from CFLAGS" \
				--enable-optimize="-Ofast"
		elif is_flagq_last '-O4' || [[ "${OFLAG}" == "-O4" ]] ; then
	# O4 is the same as O3.
			OFLAG="-O4"
			mozconfig_add_options_ac \
				"from CFLAGS" \
				--enable-optimize="-O4"
		elif is_flagq_last '-O3' || [[ "${OFLAG}" == "-O3" ]] ; then
	# Repeated for multiple Oflags
			OFLAG="-O3"
			mozconfig_add_options_ac \
				"from CFLAGS" \
				--enable-optimize="-O3"
		elif is_flagq_last '-O2' || [[ "${OFLAG}" == "-O2" ]] ; then
			OFLAG="-O2"
			mozconfig_add_options_ac \
				"from CFLAGS" \
				--enable-optimize="-O2"
		else
			OFLAG="-O3"
			mozconfig_add_options_ac \
				"Upstream default" \
				--enable-optimize="-O3"
		fi
	fi

	local oflag_safe
	if [[ -z "${OFLAG}" ]] ; then
		oflag_safe=$(get_olast)
	else
		oflag_safe="${OFLAG}"
	fi
	[[ "${oflag_safe}" == "-Ofast" ]] && oflag_safe="-O3"
	einfo "oflag_safe:\t${oflag_safe}"

	local L=(
		"dom/bindings/moz.build"
		"ipc/chromium/chromium-config.mozbuild"
		"gfx/layers/moz.build"
		"js/src/js-cxxflags.mozbuild"
	)

	local f
	for f in ${L[@]} ; do
		einfo "Editing ${f}:  __OFLAG_SAFE__ -> ${oflag_safe}"
		sed -i -e "s|__OFLAG_SAFE__|${oflag_safe}|g" \
			"${f}" \
			|| die
	done

	# Debug flag was handled via configure
	filter-flags '-g*'

	# Optimization flag was handled via configure
	filter-flags '-O*'

	if is-flagq '-ffast-math' || [[ "${OFLAG}" == "-Ofast" ]] ; then
		local pos=$(grep -n "#define OPUS_DEFINES_H" \
			"${s}/media/libopus/include/opus_defines.h" \
			| cut -f 1 -d ":")
		sed -i -e "${pos}a#define FLOAT_APPROX 1" \
			"${s}/media/libopus/include/opus_defines.h" || die
	fi

	# Modifications to better support ARM, bug #553364
	if use cpu_flags_arm_neon ; then
		mozconfig_add_options_ac '+cpu_flags_arm_neon' --with-fpu="neon"

		if tc-is-gcc ; then
	# Thumb options aren't supported when using clang, bug 666966
			mozconfig_add_options_ac \
				'+cpu_flags_arm_neon' \
				--with-thumb=yes \
				--with-thumb-interwork=no
		fi
	fi

	if [[ ${CHOST} == armv*h* ]] ; then
		mozconfig_add_options_ac 'CHOST=armv*h*' --with-float-abi="hard"

		if ! use system-libvpx ; then
			sed -i \
				-e "s|softfp|hard|" \
				"${s}/media/libvpx/moz.build" \
				|| die
		fi
	fi

	# With profile 23.0 elf-hack=legacy is broken with gcc.
	# With Firefox-115esr elf-hack=relr isn't available (only in rapid).
	# Solution: Disable build system's elf-hack completely, and add "-z,pack-relative-relocs"
	#  manually with gcc.
	#
	# elf-hack configure option isn't available on ppc64/riscv, #916259, #929244, #930046.
	if use ppc64 || use riscv ; then
		:;
	else
		mozconfig_add_options_ac 'elf-hack disabled' --disable-elf-hack
	fi

	if (is_flagq_last "-O3" || is_flagq_last "-Ofast") \
		&& tc-is-gcc \
		&& ver_test $(gcc-fullversion) -lt 11.3.0 ; then
		ewarn
		ewarn "GCC version detected:\t$(gcc-fullversion)"
		ewarn "Expected version:\t>= 11.3"
		ewarn
		ewarn "The detected version is untested and may result in userscript failure."
		ewarn "Use GCC >= 11.3 or Clang to prevent this bug."
		ewarn
	fi

	# Additional ARCH support
	case "${ARCH}" in
		arm)
			# Reduce the memory requirements for linking
			if use clang ; then
				# Nothing to do
				:;
			elif use lto ; then
				append-ldflags -Wl,--no-keep-memory
			else
				append-ldflags -Wl,--no-keep-memory -Wl,--reduce-memory-overheads
			fi
			;;
	esac

	# Use the O(1) algorithm linker algorithm and add more swap instead.
	ewarn
	ewarn "Add more swap space if linker causes an out of memory (OOM) condition."
	ewarn

	if ! use elibc_glibc ; then
		mozconfig_add_options_ac '!elibc_glibc' --disable-jemalloc
	elif ! use jemalloc ; then
		mozconfig_add_options_ac '-jemalloc' --disable-jemalloc
	else
		mozconfig_add_options_ac '+jemalloc' --enable-jemalloc
	fi

	# System-av1 fix
	use system-av1 && append-ldflags "-Wl,--undefined-version"

	# Allow elfhack to work in combination with unstripped binaries
	# when they would normally be larger than 2GiB.
	append-ldflags "-Wl,--compress-debug-sections=zlib"

	# Make revdep-rebuild.sh happy; Also required for musl
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}",--enable-new-dtags

	# Pass $MAKEOPTS to build system
	export MOZ_MAKE_FLAGS="${MAKEOPTS}"

	# Use system's Python environment
	export PIP_NETWORK_INSTALL_RESTRICTED_VIRTUALENVS="mach"

	if use system-python-libs; then
		export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE="system"
		export MACH_SYSTEM_ASSERTED_COMPATIBLE_WITH_BUILD_SITE=1
		export MACH_SYSTEM_ASSERTED_COMPATIBLE_WITH_MACH_SITE=1
	else
		export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE="none"
	fi

	# Disable notification when build system has finished
	export MOZ_NOSPAM=1

	# Portage sets XARGS environment variable to "xargs -r" by default which
	# breaks build system's check_prog() function which doesn't support arguments
	mozconfig_add_options_ac 'Gentoo default' "XARGS=${EPREFIX}/usr/bin/xargs"

	# Set build dir
	mozconfig_add_options_mk 'Gentoo default' "MOZ_OBJDIR=${BUILD_OBJ_DIR}"
	einfo "Cross-compile ABI:\t\t${ABI}"
	einfo "Cross-compile CFLAGS:\t${CFLAGS}"
	einfo "Cross-compile CC:\t\t${CC}"
	einfo "Cross-compile CXX:\t\t${CXX}"
	echo "export PKG_CONFIG=${CHOST}-pkg-config" \
		>>"${MOZCONFIG}"
	echo "export PKG_CONFIG_PATH=/usr/$(get_libdir)/pkgconfig:/usr/share/pkgconfig" \
		>>"${MOZCONFIG}"

	# Show flags we will use
	einfo "Build BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Build CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Build CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Build LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Build RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	# Handle EXTRA_CONF and show summary
	local ac opt hash reason

	# Apply EXTRA_ECONF entries to $MOZCONFIG
	if [[ -n "${EXTRA_ECONF}" ]] ; then
		IFS=\! read -a ac <<<${EXTRA_ECONF// --/\!}
		for opt in "${ac[@]}"; do
			mozconfig_add_options_ac "EXTRA_ECONF" --${opt#--}
		done
	fi

	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	grep ^ac_add_options "${MOZCONFIG}" | \
	while read ac opt hash reason; do
		[[ -z "${hash}" || "${hash}" == \# ]] \
			|| die "error reading mozconfig: ${ac} ${opt} ${hash} ${reason}"
		printf "    %-30s  %s\n" "${opt}" "${reason:-mozilla.org default}"
	done
	echo "=========================================================="
	echo

	./mach configure || die
}

src_configure() {
	multilib_foreach_abi _src_configure
}

_src_compile() {
	local s=$(_get_s)
	cd "${s}" || die

	if use mold && use lto; then
		# increase ulimit with mold+lto, bugs #892641, #907485
		if ! ulimit -n 16384 1>/dev/null 2>&1 ; then
		ewarn "Unable to modify ulimits - building with mold+lto might fail due to low"
		ewarn "ulimit -n resources."
		#ewarn "Please see bugs #892641 & #907485."
		else
			ulimit -n 16384
		fi
	fi

	local CDEFAULT=$(get_abi_CHOST "${DEFAULT_ABI}")
	_fix_paths
	local virtx_cmd=

	if use pgo; then
		# Reset and cleanup environment variables used by GNOME/XDG
		gnome2_environment_reset

		addpredict "/root"

		if ! use X; then
			virtx_cmd="virtwl"
		else
			virtx_cmd="virtx"
		fi
	fi

	if ! use X; then
		local -x GDK_BACKEND="wayland"
	else
		local -x GDK_BACKEND="x11"
	fi

	${virtx_cmd} ./mach build --verbose || die

	# Build language packs
	moz_build_xpi
}

src_compile() {
	multilib_foreach_abi _src_compile
}

_src_install() {
	local s=$(_get_s)
	cd "${s}" || die
	local CDEFAULT=$(get_abi_CHOST "${DEFAULT_ABI}")
	_fix_paths
	# xpcshell is getting called during install
	pax-mark m \
		"${BUILD_OBJ_DIR}/dist/bin/xpcshell" \
		"${BUILD_OBJ_DIR}/dist/bin/${PN}" \
		"${BUILD_OBJ_DIR}/dist/bin/plugin-container"

	DESTDIR="${D}" ./mach install || die

	# Upstream cannot ship symlink but we can (bmo#658850)
	rm "${ED}${MOZILLA_FIVE_HOME}/${PN}-bin" || die
	dosym "${PN}" "${MOZILLA_FIVE_HOME}/${PN}-bin"

	# Don't install llvm-symbolizer from sys-devel/llvm package
	if [[ -f "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] ; then
		rm -v "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" || die
	fi

	# Install policy (currently only used to disable application updates)
	insinto "${MOZILLA_FIVE_HOME}/distribution"
	newins "${FILESDIR}/distribution.ini" "distribution.ini"
	newins "${FILESDIR}/disable-auto-update.policy.json" "policies.json"

	# Install system-wide preferences
	local PREFS_DIR="${MOZILLA_FIVE_HOME}/browser/defaults/preferences"
	insinto "${PREFS_DIR}"
	newins "${FILESDIR}/gentoo-default-prefs.js" "gentoo-prefs.js"

	local GENTOO_PREFS="${ED}${PREFS_DIR}/gentoo-prefs.js"

	# Set dictionary path to use system hunspell
	cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set spellchecker.dictionary_path pref"
	pref("spellchecker.dictionary_path",       "${EPREFIX}/usr/share/myspell");
	EOF

	# Set installDistroAddons to true so that language packs work
	cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set extensions.installDistroAddons pref"
	pref("extensions.installDistroAddons",     true);
	pref("extensions.langpacks.signatures.required",	false);
	EOF

	# Disable signatures for language packs so that unsigned just built language packs work
	cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to disable langpacks signatures"
	pref("extensions.langpacks.signatures.required",	false);
	EOF

	# Force hwaccel prefs if USE=hwaccel is enabled
	if use hwaccel ; then
		cat "${FILESDIR}/gentoo-hwaccel-prefs.js-r2" \
		>>"${GENTOO_PREFS}" \
		|| die "failed to add prefs to force hardware-accelerated rendering to all-gentoo.js"

		if use wayland; then
			cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set hwaccel wayland prefs"
			pref("gfx.x11-egl.force-enabled",          false);
			EOF
		else
			cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set hwaccel x11 prefs"
			pref("gfx.x11-egl.force-enabled",          true);
			EOF
		fi
	fi

	# Force the graphite pref if USE=system-harfbuzz is enabled, since the pref cannot disable it
	if use system-harfbuzz ; then
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set gfx.font_rendering.graphite.enabled pref"
		sticky_pref("gfx.font_rendering.graphite.enabled", true);
		EOF
	fi

	# Install language packs
	local langpacks=( $(find "${BUILD_OBJ_DIR}/dist/linux-x86_64/xpi" -type f -name '*.xpi') )
	if [[ -n "${langpacks}" ]] ; then
		moz_install_xpi "${MOZILLA_FIVE_HOME}/distribution/extensions" "${langpacks[@]}"
	fi

	# Install geckodriver
	if use geckodriver ; then
		einfo "Installing geckodriver into ${ED}${MOZILLA_FIVE_HOME} ..."
		pax-mark m "${BUILD_OBJ_DIR}/dist/bin/geckodriver"
		exeinto "${MOZILLA_FIVE_HOME}"
		doexe "${BUILD_OBJ_DIR}/dist/bin/geckodriver"

		dosym "${MOZILLA_FIVE_HOME}/geckodriver" "/usr/bin/geckodriver"
	fi

	# Install icons
	local icon_srcdir="${s}/browser/branding/official"
	local icon_symbolic_file="${FILESDIR}/icon/${PN}-symbolic.svg"

	insinto /usr/share/icons/hicolor/symbolic/apps
	newins "${icon_symbolic_file}" "${PN}-symbolic.svg"

	local icon size
	for icon in "${icon_srcdir}/default"*".png" ; do
		size=${icon%.png}
		size=${size##*/default}

		if [[ ${size} -eq 48 ]] ; then
			newicon "${icon}" "${PN}.png"
		fi

		newicon -s ${size} "${icon}" "${PN}.png"
	done

	# Install menu
	local app_name="GNU IceCat"
	local desktop_file="${FILESDIR}/icon/${PN}-r3.desktop"
	local desktop_filename="${PN}-esr-${ABI}.desktop"
	local exec_command="${PN}-${ABI}"
	local icon="${PN}"
	local use_wayland="false"

	if use wayland ; then
		use_wayland="true"
	fi

	cp "${desktop_file}" "${WORKDIR}/${PN}.desktop-template" || die

	sed -i \
		-e "s:@NAME@:${app_name}:" \
		-e "s:@EXEC@:${exec_command}:" \
		-e "s:@ICON@:${icon}:" \
		"${WORKDIR}/${PN}.desktop-template" \
		|| die

	newmenu "${WORKDIR}/${PN}.desktop-template" "${desktop_filename}"

	rm "${WORKDIR}/${PN}.desktop-template" || die

	# Install wrapper script
	[[ -f "${ED}/usr/bin/${PN}" ]] && rm "${ED}/usr/bin/${PN}"
	newbin "${FILESDIR}/${PN}-r1.sh" "${PN}-${ABI}"
	dosym "/usr/bin/${PN}-${ABI}" "/usr/bin/${PN}"

	# Update wrapper
	sed -i \
		-e "s:@PREFIX@:${EPREFIX}/usr:" \
		-e "s:@LIBDIR@:$(get_libdir):" \
		-e "s:@MOZ_FIVE_HOME@:${MOZILLA_FIVE_HOME}:" \
		-e "s:@APULSELIB_DIR@:${apulselib}:" \
		-e "s:@DEFAULT_WAYLAND@:${use_wayland}:" \
		"${ED}/usr/bin/${PN}-${ABI}" \
		|| die
}

src_install() {
	install_abi() {
		_src_install
		multilib_check_headers
	}
	multilib_foreach_abi install_abi
}

pkg_preinst() {
	xdg_pkg_preinst

	# If the apulse libs are available in MOZILLA_FIVE_HOME then apulse
	# does not need to be forced into the LD_LIBRARY_PATH
	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
		einfo "APULSE found; Generating library symlinks for sound support ..."
		local lib
		pushd "${ED}${MOZILLA_FIVE_HOME}" &>/dev/null || die
		for lib in "../apulse/libpulse"{".so"{"",".0"},"-simple.so"{"",".0"}} ; do
			# A quickpkg rolled by hand will grab symlinks as part of the package,
			# so we need to avoid creating them if they already exist.
			if [[ ! -L "${lib##*/}" ]] ; then
				ln -s "${lib}" "${lib##*/}" || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Cloudflare browser checks are broken with GNU IceCats anti fingerprinting measures."
	elog "You can fix cloudflare browser checks by undoing them in about:config like below:"
	# Specifying (X11) is necessary for it to work, even in a Wayland session
	elog "   general.appversion.override: ${PV%.[0-9]*} (X11)"
	elog "   general.oscpu.override: Linux x86_64"
	elog "   general.platform.override: Linux x86_64"

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
		elog "Apulse was detected at merge time on this system and so it will always be"
		elog "used for sound.  If you wish to use pulseaudio instead please unmerge"
		elog "media-sound/apulse."
		elog
	fi

	if ! use hwaccel ; then
		ewarn
		ewarn "You must manually enable \"Use hardware acceleration when available\""
		ewarn "for smoother scrolling and >= 25 FPS video playback."
		ewarn
		ewarn "For details, see https://support.mozilla.org/en-US/kb/performance-settings"
		ewarn
	fi
	if use libcanberra ; then
		if has_version "media-libs/libcanberra[-sound]" ; then
			ewarn
			ewarn "You need a sound theme to hear notifications."
			ewarn "The default one can be installed with media-libs/libcanberra[sound]"
			ewarn
		fi
	fi

	# bug 835078
	if use hwaccel && has_version "x11-drivers/xf86-video-nouveau"; then
		ewarn "You have nouveau drivers installed in your system and 'hwaccel' "
		ewarn "enabled for IceCat. Nouveau / your GPU might not support the "
		ewarn "required EGL, so either disable 'hwaccel' or try the workaround "
		ewarn "explained in https://bugs.gentoo.org/835078#c5 if Firefox crashes."
	fi

	readme.gentoo_print_elog

	optfeature_header "Optional programs for extra features:"
	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "fallback mouse cursor theme e.g. on WMs" gnome-base/gsettings-desktop-schemas
	optfeature "screencasting with pipewire" sys-apps/xdg-desktop-portal
	if use hwaccel && has_version "x11-drivers/nvidia-drivers"; then
		optfeature "hardware acceleration with NVIDIA cards" media-libs/nvidia-vaapi-driver
	fi

	if ! has_version "sys-libs/glibc"; then
		elog
		elog "glibc not found! You won't be able to play DRM content."
		elog "See Gentoo bug #910309 or upstream bug #1843683."
		elog
	fi

	if use geckodriver ; then
		ewarn "You have enabled the 'geckodriver' USE flag. Geckodriver is now"
		ewarn "packaged separately as net-misc/geckodriver and the use flag will be"
		ewarn "dropped from main Firefox package by Firefox 128.0 release."
	fi
}
