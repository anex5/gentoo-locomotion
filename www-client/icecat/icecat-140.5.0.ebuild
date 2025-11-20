# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Using Gentoos firefox patches as system libraries and lto are quite nice
FIREFOX_PATCHSET="firefox-${PV%%.*}esr-patches-03.tar.xz"
FIREFOX_LOONG_PATCHSET="firefox-139-loong-patches-02.tar.xz"

LLVM_COMPAT=( {19..21} )
PP="2"
GV="1"

# This will also filter rust versions that don't match LLVM_COMPAT in the non-clang path; this is fine.
RUST_NEEDS_LLVM=1
# If not building with clang we need at least rust 1.76
RUST_MIN_VER=1.82.0

PYTHON_COMPAT=( python3_{11..14} )
PYTHON_REQ_USE="ncurses,sqlite,ssl"

VIRTUALX_REQUIRED="manual"

# Information about the bundled wasi toolchain from
# https://github.com/WebAssembly/wasi-sdk/
WASI_SDK_VER=28.0
WASI_SDK_LLVM_VER=${LLVM_SLOT}

MOZ_ESR=yes

inherit autotools check-reqs desktop flag-o-matic gnome2-utils linux-info llvm-r1 multiprocessing \
	multilib-minimal optfeature pax-utils python-any-r1 readme.gentoo-r1 rust toolchain-funcs unpacker virtualx xdg

SRC_URI="
	!buildtarball? (
		https://gitlab.com/api/v4/projects/32909921/packages/generic/${PN}/${PV}-${PP}gnu${GV}/${P}-${PP}gnu${GV}.tar.zst
	)
	https://dev.gentoo.org/~juippis/mozilla/patchsets/${FIREFOX_PATCHSET}
	loong? (
		https://dev.gentoo.org/~xen0n/distfiles/www-client/firefox/${FIREFOX_LOONG_PATCHSET}
	)
	wasm-sandbox? (
		amd64? ( https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_VER/.*/}/wasi-sdk-${WASI_SDK_VER}-x86_64-linux.tar.gz )
		arm64? ( https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_VER/.*/}/wasi-sdk-${WASI_SDK_VER}-arm64-linux.tar.gz )
	)
"

DESCRIPTION="GNU IceCat Web Browser"
HOMEPAGE="https://www.gnu.org/software/gnuzilla/"


LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~riscv ~x86"

CODEC_IUSE="
-aac
+dav1d
-h264
+opus
+vpx
+openh264
"
IUSE+="
${CODEC_IUSE}
alsa atk buildtarball clang cpu_flags_arm_neon cups +dbus debug firejail hardened hwaccel
jack -jemalloc +jit libcanberra libnotify libproxy libsecret lld lto mold pgo
pulseaudio sndio selinux speech +system-av1 +system-ffmpeg +system-harfbuzz
+system-icu +system-jpeg +system-libevent +system-libvpx +system-png +system-pipewire
-system-python-libs +system-webp test vaapi wayland +webrtc wifi webspeech X
"

# Firefox-only IUSE
IUSE+=" gnome-shell screencast +jumbo-build wasm-sandbox"

REQUIRED_USE="
	aac? (
		system-ffmpeg
	)
	dav1d? (
		system-ffmpeg
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
		system-ffmpeg
	)
	vpx? (
		system-ffmpeg
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
	pgo? ( jumbo-build )
"
RESTRICT="!test? ( test ) mirror"
# Firefox-only REQUIRED_USE flags
REQUIRED_USE+=" screencast? ( wayland )"

DBUS_PV="0.60"
DBUS_GLIB_PV="0.60"
FFMPEG_PV="6.1.3" # This corresponds to y in x.y.z from the subslot.
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
			>=dev-python/aiohttp-3.10.11[${PYTHON_USEDEP}]
			>=dev-python/aiosignal-1.3.1[${PYTHON_USEDEP}]
			>=dev-python/appdirs-1.4.4[${PYTHON_USEDEP}]
			>=dev-python/arrow-1.3.0[${PYTHON_USEDEP}]
			>=dev-python/async-timeout-5.0.1[${PYTHON_USEDEP}]
			>=dev-python/attrs-23.1.0[${PYTHON_USEDEP}]
			>=dev-python/binaryornot-0.4.4[${PYTHON_USEDEP}]
			>=dev-python/blessed-1.19.1[${PYTHON_USEDEP}]
			>=dev-python/build-1.2.2[${PYTHON_USEDEP}]
			>=dev-python/cbor2-4.0.1[${PYTHON_USEDEP}]
			>=dev-python/certifi-2024.7.4[${PYTHON_USEDEP}]
			>=dev-python/chardet-5.2.0[${PYTHON_USEDEP}]
			>=dev-python/charset-normalizer-3.4.2[${PYTHON_USEDEP}]
			>=dev-python/click-8.1.7[${PYTHON_USEDEP}]
			>=dev-python/colorama-0.4.6[${PYTHON_USEDEP}]
			>=dev-util/cookiecutter-2.6.0[${PYTHON_USEDEP}]
			>=dev-python/cookies-2.2.1[${PYTHON_USEDEP}]
			>=dev-python/diskcache-5.6.3[${PYTHON_USEDEP}]
			>=dev-python/distro-1.8.0[${PYTHON_USEDEP}]
			>=dev-python/ecdsa-0.19.1[${PYTHON_USEDEP}]
			>=dev-python/filelock-3.16.1[${PYTHON_USEDEP}]
			>=dev-python/frozenlist-1.5.0[${PYTHON_USEDEP}]
			>=dev-python/idna-3.10[${PYTHON_USEDEP}]
			>=dev-python/importlib-metadata-6.0.0[${PYTHON_USEDEP}]
			>=dev-python/iniparse-0.5[${PYTHON_USEDEP}]
			>=dev-python/jinja2-3.1.6[${PYTHON_USEDEP}]
			>=dev-python/jsmin-3.0.0[${PYTHON_USEDEP}]
			>=dev-python/jsonschema-4.17.3[${PYTHON_USEDEP}]
			>=dev-python/looseversion-1.0.1[${PYTHON_USEDEP}]
			>=dev-python/mako-1.2.2[${PYTHON_USEDEP}]
			>=dev-python/markdown-it-py-3.0.0[${PYTHON_USEDEP}]
			>=dev-python/markupsafe-2.0.1[${PYTHON_USEDEP}]
			>=dev-python/mdurl-0.1.2[${PYTHON_USEDEP}]
			>=dev-python/multidict-6.1.0[${PYTHON_USEDEP}]
			>=dev-python/packaging-23.1[${PYTHON_USEDEP}]
			>=dev-python/pathspec-0.9.0[${PYTHON_USEDEP}]
			>=dev-python/pip-24.0[${PYTHON_USEDEP}]
			>=dev-python/platformdirs-4.3.6[${PYTHON_USEDEP}]
			>=dev-python/ply-3.10[${PYTHON_USEDEP}]
			>=dev-python/polib-1.2.0[${PYTHON_USEDEP}]
			>=dev-python/propcache-0.2.0[${PYTHON_USEDEP}]
			>=dev-python/pyasn1-0.4.8[${PYTHON_USEDEP}]
			>=dev-python/pyasn1-modules-0.2.8[${PYTHON_USEDEP}]
			>=dev-python/pygments-2.19.1[${PYTHON_USEDEP}]
			>=dev-python/pylru-1.0.9[${PYTHON_USEDEP}]
			>=dev-python/pyproject-hooks-1.2.0[${PYTHON_USEDEP}]
			>=dev-python/pyrsistent-0.20.0[${PYTHON_USEDEP}]
			>=dev-python/python-dateutil-2.9.0[${PYTHON_USEDEP}]
			>=dev-python/python-slugify-8.0.4[${PYTHON_USEDEP}]
			>=dev-python/pyyaml-6.0.1[${PYTHON_USEDEP}]
			>=dev-python/requests-2.32.3[${PYTHON_USEDEP}]
			>=dev-python/requests-unixsocket-0.2.0[${PYTHON_USEDEP}]
			>=dev-python/responses-0.10.6[${PYTHON_USEDEP}]
			>=dev-python/rich-14.0.0[${PYTHON_USEDEP}]
			>=dev-python/rsa-4.9[${PYTHON_USEDEP}]
			>=dev-python/six-1.16.0[${PYTHON_USEDEP}]
			>=dev-python/toml-0.10.2[${PYTHON_USEDEP}]
			>=dev-python/tomli-2.2.1[${PYTHON_USEDEP}]
			>=dev-python/tomlkit-0.12.3[${PYTHON_USEDEP}]
			>=dev-python/tqdm-4.66.3[${PYTHON_USEDEP}]
			>=dev-python/typing-extensions-4.12.2[${PYTHON_USEDEP}]
			>=dev-python/urllib3-1.26.19[${PYTHON_USEDEP}]
			>=dev-python/voluptuous-0.12.1[${PYTHON_USEDEP}]
			>=dev-python/wcwidth-0.2.13[${PYTHON_USEDEP}]
			>=dev-python/wheel-0.43.0[${PYTHON_USEDEP}]
			>=dev-python/yarl-1.15.2[${PYTHON_USEDEP}]
			>=dev-python/zipp-3.20.2[${PYTHON_USEDEP}]
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
		>=media-libs/libaom-3.10.0:=[${MULTILIB_USEDEP}]
	)
	system-harfbuzz? (
		!wasm-sandbox? ( >=media-gfx/graphite2-1.3.14 )
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
	system-pipewire? (
		>=media-video/pipewire-1.4.7-r2:=[${MULTILIB_USEDEP}]
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
	hwaccel? (
		media-video/libva-utils
		sys-apps/pciutils
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
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/llvm:${LLVM_SLOT}
		clang? (
			llvm-core/lld:${LLVM_SLOT}
			pgo? ( llvm-runtimes/compiler-rt-sanitizers:${LLVM_SLOT}[profile] )
		)
		wasm-sandbox? ( llvm-core/lld:${LLVM_SLOT} )
	')
	>=dev-util/cbindgen-0.24.3
	>=dev-util/pkgconf-1.8.0[${MULTILIB_USEDEP},pkg-config(+)]
	>=net-libs/nodejs-21[${MULTILIB_USEDEP}]
	|| (
		>=dev-lang/rust-1.83.0[${MULTILIB_USEDEP}]
		>=dev-lang/rust-bin-1.83.0[${MULTILIB_USEDEP}]
		<dev-lang/rust-1.92.0[${MULTILIB_USEDEP}]
		<dev-lang/rust-bin-1.92.0[${MULTILIB_USEDEP}]
	)
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
		llvm-core/lld
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
			gui-wm/tinywl
			x11-misc/xkeyboard-config
		)
	)
	x86? (
		>=dev-lang/nasm-${NASM_PV}
	)
"
PDEPEND+="
	firejail? (
		sys-apps/firejail[X?]
	)
	screencast? (
		>=media-video/pipewire-0.3.52[${MULTILIB_USEDEP}]
		sys-apps/xdg-desktop-portal
	)
"

RESTRICT="mirror"

S="${WORKDIR}/${PN}-${PV%_*}"

llvm_check_deps() {
	if ! has_version -b "llvm-core/clang:${LLVM_SLOT}" ; then
		einfo "llvm-core/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang && ! use mold ; then
		if ! has_version -b "llvm-core/lld:${LLVM_SLOT}" ; then
			einfo "llvm-core/lld:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi
		if ! has_version -b "dev-lang/rust:0/llvm-${LLVM_SLOT}" && ! has_version -b "dev-lang/rust-bin:0/llvm-${LLVM_SLOT}"; then
			einfo "dev-lang/rust:0/llvm-${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if use pgo ; then
			if ! has_version -b "=llvm-runtimes/compiler-rt-sanitizers-${LLVM_SLOT}*[profile]" ; then
				einfo "=llvm-runtimes/compiler-rt-sanitizers-${LLVM_SLOT}*[profile] is missing!"
				einfo "Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
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
MOZ_LANGS+=( skr )
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
		"${S}"/third_party/rust/${1}/.cargo-checksum.json || die
}

moz_build_xpi() {
	debug-print-function ${FUNCNAME} "$@"

	local MOZ_TOO_REGIONALIZED_FOR_L10N=(
		fy-NL ga-IE gu-IN hi-IN hy-AM nb-NO ne-NP nn-NO pa-IN sv-SE
	)

	cd "${BUILD_DIR}"/browser/locales || die
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
		if use pgo || use debug ; then
			CHECKREQS_DISK_BUILD="14300M"
		elif use lto ; then
			CHECKREQS_DISK_BUILD="10600M"
		else
			CHECKREQS_DISK_BUILD="7400M"
		fi

		check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]] ; then

		if use pgo ; then
			if ! has userpriv ${FEATURES} ; then
				eerror "Building ${PN} with USE=pgo and FEATURES=-userpriv is not supported!"
			fi
		fi
		if use lto; then
			# -Werror=lto-type-mismatch -Werror=odr are going to fail with GCC,
			# bmo#1516758, bgo#942288
			filter-lto
			filter-flags -Werror=lto-type-mismatch -Werror=odr
		fi

		# Ensure we have enough disk space to compile
		if use pgo || use debug ; then
			CHECKREQS_DISK_BUILD="14300M"
		elif use lto ; then
			CHECKREQS_DISK_BUILD="10600M"
		else
			CHECKREQS_DISK_BUILD="7400M"
		fi

		check-reqs_pkg_setup
		llvm-r1_pkg_setup
		rust_pkg_setup
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
	unpack "${FIREFOX_PATCHSET}"
	if use buildtarball; then
		unpack "icecat-${PV}-${PP}gnu${GV}.tar.bz2" || eerror "Tarball is missing, check that www-client/makeicecat has use flag buildtarball enabled."
	else
		unpacker "icecat-${PV}-${PP}gnu${GV}.tar.zst" || eerror "Failed to unpack."
	fi
}

_get_s() {
	if (( ${NABIS} == 1 )) ; then
		echo "${S}"
	else
		echo "${S}-${MULTILIB_ABI_FLAG}.${ABI}"
	fi
}

src_prepare() {
	use atk || eapply "${FILESDIR}/icecat-no-atk.patch"
	use dbus || eapply "${FILESDIR}/icecat-no-dbus.patch"
	eapply "${FILESDIR}/icecat-no-fribidi.patch"
	eapply "${FILESDIR}/icecat-fix-clang-as.patch"
	eapply "${FILESDIR}/icecat-system-gtests.patch"

	if use lto; then
		rm -v "${WORKDIR}"/firefox-patches/*-LTO-Only-enable-LTO-*.patch || die
		rm -v "${WORKDIR}"/firefox-patches/*-gcc-lto-pgo-gentoo.patch || die
	fi

	#if ! use ppc64; then
	#	rm -v "${WORKDIR}"/firefox-patches/*ppc64*.patch
	#fi

	if use x86 && use elibc_glibc ; then
		rm -v "${WORKDIR}"/firefox-patches/*-musl-non-lfs64-api-on-audio_thread_priority-crate.patch || die
	fi

	eapply "${FILESDIR}/extra-patches/firefox-140.2.0e-disallow-store-data-races.patch"

	# Flicker prevention with -Ofast
	eapply "${FILESDIR}/extra-patches/firefox-106.0.2-disable-broken-flags-gfx-layers.patch"

	# Prevent YT stall prevention with clang with -Ofast.
	# Prevent audio perma mute with gcc with -Ofast.
	eapply "${FILESDIR}/extra-patches/firefox-128.3.0e-disable-broken-flags-js.patch"

	# Only partial patching was done because the distro doesn't support
	# multilib Python.  Only native ABI is supported.  This means cbindgen
	# cannot load the 32-bit clang.  It will build the cargo parts.  When it
	# links it, it fails because of cbindings is 64-bit and the dependencies
	# use the build information for 64-bit linking, which should be 32-bit.

	#eapply "${DISTDIR}/${PN}-d4f5769.patch"
	#eapply "${FILESDIR}/extra-patches/firefox-115e-remove-distutils-PR-18d19413472f.patch"
	#eapply "${FILESDIR}/extra-patches/firefox-115e-python3.12-bug1874280.patch"
	#eapply "${FILESDIR}/extra-patches/firefox-115e-python3.12-bug1866829.patch"
	#eapply "${FILESDIR}/extra-patches/firefox-115e-python3.12-bug1860051.patch"
	#eapply "${FILESDIR}/extra-patches/firefox-115e-python3.12-bug1831512.patch"
	#eapply "${FILESDIR}/extra-patches/firefox-115e-PR-b1cc62489fae.patch"
	#[[ "${EPYTHON//python}" == "3.13" ]] && eapply "${FILESDIR}/extra-patches/firefox-115e-python3.13-build-fix.patch"

	# Allow to use system-ffmpeg completely.
	if use system-ffmpeg; then
		#eapply "${FILESDIR}/extra-patches/firefox-115e-allow-ffmpeg-decode-av1.patch"
		eapply "${FILESDIR}/extra-patches/firefox-128e-disable-ffvpx.patch"
	fi

	# Prevent tab crash
	eapply "${FILESDIR}/extra-patches/firefox-140.3.1-disable-broken-flags-dom-bindings.patch"

	# Prevent video seek bug
	eapply "${FILESDIR}/extra-patches/firefox-122.0-disable-broken-flags-ipc-chromium-chromium-config.patch"


	# Build with clang-20
	if [[ "${LLVM_SLOT}" =~ ("20"|"21") ]]; then
		#eapply "${FILESDIR}/icecat-128.12.0-clang21.patch"
		sed -e '/CXXFLAGS += \["-Werror=implicit-int-conversion"\]/d' -i "${S}/dom/canvas/moz.build" -i "${S}/dom/webgpu/moz.build" || die
	fi

	#eapply "${FILESDIR}/extra-patches/firefox-128.3.0e-allow-flac-no-ffvpx.patch"
	eapply "${FILESDIR}/extra-patches/firefox-128.3.0e-big-endian-image-decoders.patch"

	# Workaround for bgo#915651 on musl
	if use elibc_glibc ; then
		rm -v "${WORKDIR}"/firefox-patches/*bgo-748849-RUST_TARGET_override.patch || die
	fi

	# Use modified patch that isn't mangled
	for patch in 0013-gcc-lto-pgo-gentoo.patch 0016-bgo-929967-fix-pgo-on-musl.patch; do
		cp "${FILESDIR}/${patch}" "${WORKDIR}/firefox-patches/${patch}" || die
	done
	# Modify patch to apply correctly
	#sed -i -e 's/Firefox/IceCat/' "${WORKDIR}"/firefox-patches/0016-bgo-929967-fix-pgo-on-musl.patch || die

	eapply "${WORKDIR}/firefox-patches"
	use loong && eapply "${WORKDIR}/firefox-loong-patches"

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
		elif use loong; then
			# Only the LP64D ABI of LoongArch64 is actively supported among
			# the wider Linux ecosystem, so the assumption is safe.
			export RUST_TARGET="loongarch64-unknown-linux-musl"
		elif use ppc64 ; then
			export RUST_TARGET="powerpc64le-unknown-linux-musl"
		elif use riscv ; then
			# We can pretty safely rule out any 32-bit riscvs, but 64-bit riscvs also have tons of
			# different ABIs available. riscv64gc-unknown-linux-musl seems to be the best working
			# guess right now though.
			elog "riscv detected, forcing a riscv64 target for now."
			export RUST_TARGET="riscv64gc-unknown-linux-musl"
		else
			eerror
			eerror "Unknown musl chost, please post your rustc -vV along with"
			eerror "\`emerge --info\` on Gentoo's bug #915651"
			eerror
			die
		fi
	fi

	# Pre-built wasm-sandbox path manipulation.
	if use wasm-sandbox ; then
		if use amd64 ; then
			export wasi_arch="x86_64"
		elif use arm64 ; then
			export wasi_arch="arm64"
		else
			die "wasm-sandbox enabled on unknown/unsupported arch!"
		fi

		sed -i \
			-e "s:%%PORTAGE_WORKDIR%%:${WORKDIR}:" \
			-e "s:%%WASI_ARCH%%:${wasi_arch}:" \
			-e "s:%%WASI_SDK_VER%%:${WASI_SDK_VER}:" \
			-e "s:%%WASI_SDK_LLVM_VER%%:${WASI_SDK_LLVM_VER}:" \
			toolkit/moz.configure || die "Failed to update wasi-related paths."
	fi

	# Make LTO & ICU respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/build/moz.configure/lto-pgo.configure \
		"${S}"/intl/icu_sources_data.py \
		"${S}"/python/mozbuild/mozbuild/base.py \
		"${S}"/third_party/chromium/build/toolchain/get_cpu_count.py \
		"${S}"/third_party/chromium/build/toolchain/get_concurrent_links.py \
		"${S}"/third_party/python/gyp/pylib/gyp/input.py \
		"${S}"/python/mozbuild/mozbuild/code_analysis/mach_commands.py \
		|| die "Sed failed."

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

	# Clear checksums from cargo crates we've manually patched.
	# moz_clear_vendor_checksums crate

	# Respect choice for "jumbo-build"
	# Changing the value for FILES_PER_UNIFIED_FILE may not work, see #905431
	if [[ -n ${FILES_PER_UNIFIED_FILE} ]] && use jumbo-build; then
		local my_files_per_unified_file=${FILES_PER_UNIFIED_FILE:=16}
		elog ""
		elog "jumbo-build defaults modified to ${my_files_per_unified_file}."
		elog "if you get a build failure, try undefining FILES_PER_UNIFIED_FILE,"
		elog "if that fails try -jumbo-build before opening a bug report."
		elog ""

		sed -i -e "s/\"FILES_PER_UNIFIED_FILE\", 16/\"FILES_PER_UNIFIED_FILE\", "${my_files_per_unified_file}"/" \
			python/mozbuild/mozbuild/frontend/data.py ||
				die "Failed to adjust FILES_PER_UNIFIED_FILE in python/mozbuild/mozbuild/frontend/data.py"
		sed -i -e "s/FILES_PER_UNIFIED_FILE = 6/FILES_PER_UNIFIED_FILE = "${my_files_per_unified_file}"/" \
			js/src/moz.build ||
				die "Failed to adjust FILES_PER_UNIFIED_FILE in js/src/moz.build"
	fi
	# Removed creation of a single build dir

	# Clear cargo checksums from crates we have patched
	# moz_clear_vendor_checksums crate
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
		local version_clang=$(${CC} --version 2>/dev/null \
			| grep -F -- 'clang version' \
			| awk '{ print $3 }')
		if [[ -n "${version_clang}" ]] ; then
			version_clang=$(ver_cut 1 "${version_clang}")
		else
			eerror "Failed to read clang version!"
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

is_flagq_last() {
	local flag="${1}"
	local olast=$(echo "${CFLAGS}" \
		| grep -o -E -e "-O(0|1|z|s|2|3|4|fast)" \
		| tr " " "\n" \
		| tail -n 1)
einfo "CFLAGS:\t${CFLAGS}"
einfo "olast:\t${olast}"
	[[ "${flag}" == "${olast}" ]] && return 0
	return 1
}

get_olast() {
	local olast=$(echo "${CFLAGS}" \
		| grep -o -E -e "-O(0|1|z|s|2|3|4|fast)" \
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
	if use clang; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."

		local version_clang=$(clang --version 2>/dev/null | grep -F -- 'clang version' | awk '{ print $3 }')
		[[ -n ${version_clang} ]] && version_clang=$(ver_cut 1 "${version_clang}")
		[[ -z ${version_clang} ]] && die "Failed to read clang version!"

		if tc-is-gcc; then
			have_switched_compiler=yes
		fi

		AR=llvm-ar
		CC=${CHOST}-clang-${version_clang}
		CXX=${CHOST}-clang++-${version_clang}
		NM=llvm-nm
		RANLIB=llvm-ranlib
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		have_switched_compiler=yes
		einfo "Enforcing the use of gcc due to USE=-clang ..."
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
	export AS="$(tc-getCC) -c"

	if use clang ; then
		# Configuration tests expect llvm-readelf output, bug 913130
		READELF="llvm-readelf"
	fi

	tc-export CC CXX LD AR AS NM OBJDUMP RANLIB READELF PKG_CONFIG
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
	# MOZILLA_FIVE_HOME is dynamically generated per ABI in _fix_paths().
	#export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	# Set state path
	export MOZBUILD_STATE_PATH="${BUILD_DIR}"

	# MOZCONFIG is dynamically generated per ABI in _fix_paths().
	#export MOZCONFIG="${s}/.mozconfig"
	# Set Gentoo defaults
	export MOZILLA_OFFICIAL=1
	# Initialize MOZCONFIG
	mozconfig_add_options_ac '' --enable-application="browser"
	mozconfig_add_options_ac '' --enable-project="browser"

	mozconfig_add_options_ac \
		'Gentoo default' \
		--allow-addon-sideload \
		--disable-cargo-incremental \
		--disable-crashreporter \
		--disable-disk-remnant-avoidance \
		--disable-geckodriver \
		--disable-eme \
		--disable-install-strip \
		--disable-legacy-profile-creation \
		--disable-parental-controls \
		--disable-strip \
		--disable-updater \
		--disable-valgrind \
		--disable-wmf \
		--enable-negotiateauth \
		--enable-new-pass-manager \
		--enable-official-branding \
		--enable-packed-relative-relocs \
		--enable-release \
		--enable-system-ffi \
		--enable-system-pixman \
		--enable-system-policies \
		--host="${CDEFAULT}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--prefix="${EPREFIX}/usr" \
		--target="${CHOST}" \
		--without-ccache \
		--with-intl-api \
		--with-l10n-base="${s}/l10n" \
		--with-system-ffi \
		--with-system-gbm \
		--with-system-libdrm \
		--with-system-nspr \
		--with-system-nss \
		--with-system-pixman \
		--with-system-zlib \
		--with-toolchain-prefix="${CHOST}-" \
		--with-unsigned-addon-scopes="app,system"

	if use system-ffmpeg ; then
		mozconfig_add_options_ac \
			'+system-ffmpeg' \
			--enable-ffmpeg
	else
		mozconfig_add_options_ac \
			'-system-ffmpeg' \
			--disable-ffmpeg
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

	if use jit ; then
		mozconfig_add_options_ac 'Enabling JIT' --enable-jit
	else
		mozconfig_add_options_ac 'Disabling JIT' --disable-jit
	fi

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
	mozconfig_use_with system-pipewire
	mozconfig_use_with system-png
	mozconfig_use_with system-webp

	mozconfig_use_enable atk accessibility
	mozconfig_use_enable dbus
	mozconfig_use_enable libproxy
	mozconfig_use_enable cups printing
	multilib_is_native_abi && mozconfig_use_enable speech synth-speechd
	mozconfig_use_enable webrtc
	mozconfig_use_enable webspeech

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

	mozconfig_add_options_ac '--enable-audio-backends' \
		--enable-audio-backends=$(echo "${myaudiobackends}" | sed -e "s|,$||g") # Cannot be empty

	mozconfig_use_enable wifi necko-wifi

	! use jumbo-build && mozconfig_add_options_ac '--disable-unified-build' --disable-unified-build

	if use X && use wayland ; then
		mozconfig_add_options_ac '+x11+wayland' --enable-default-toolkit="cairo-gtk3-x11-wayland"
	elif ! use X && use wayland ; then
		mozconfig_add_options_ac '+wayland' --enable-default-toolkit="cairo-gtk3-wayland-only"
	else
		mozconfig_add_options_ac '+x11' --enable-default-toolkit="cairo-gtk3-x11-only"
	fi

	# wasm-sandbox
	# Since graphite2 is one of the sandboxed libraries, system-graphite2 obviously can't work with +wasm-sandbox.
	if use wasm-sandbox ; then
		mozconfig_add_options_ac '+wasm-sandbox' --with-wasi-sysroot="${WORKDIR}/wasi-sdk-${WASI_SDK_VER}-${wasi_arch}-linux/share/wasi-sysroot/"
	else
		mozconfig_add_options_ac 'no wasm-sandbox' --without-wasm-sandboxed-libraries
		mozconfig_use_with system-harfbuzz system-graphite2
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
		mozconfig_add_options_ac '+debug' --disable-optimize
		mozconfig_add_options_ac '+debug' --enable-jemalloc
		mozconfig_add_options_ac '+debug' --enable-real-time-tracing
	else
		mozconfig_add_options_ac 'Gentoo default' --disable-real-time-tracing
		if is-flag '-g*' ; then
			if use clang ; then
				mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols=$(get-flag '-g*')
			else
				mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols
			fi
		else
			mozconfig_add_options_ac 'Gentoo default' --disable-debug-symbols
		fi

		if is_flagq_last '-Ofast' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize="-Ofast"
		elif is-flag '-O0' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O0
		elif is-flag '-O4' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O4
		elif is-flag '-O3' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O3
		elif is-flag '-O1' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O1
		elif is-flag '-Os' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-Os
		else
			mozconfig_add_options_ac "Gentoo default" --enable-optimize=-O2
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
		mozconfig_add_options_ac 'disable elf-hack on non-supported arches' --disable-elf-hack
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

	mozconfig_use_enable test tests

	# Disable notification when build system has finished
	export MOZ_NOSPAM=1

	# Portage sets XARGS environment variable to "xargs -r" by default which
	# breaks build system's check_prog() function which doesn't support arguments
	mozconfig_add_options_ac 'Gentoo default' "XARGS=${EPREFIX}/usr/bin/xargs"

	# Set build dir
	mozconfig_add_options_mk 'Gentoo default' "MOZ_OBJDIR=${BUILD_DIR}"
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

src_test() {
	# https://firefox-source-docs.mozilla.org/testing/automated-testing/index.html
	local -a failures=()

	# Some tests respect this
	local -x MOZ_HEADLESS=1

	# Check testing/mach_commands.py
	einfo "Testing with cppunittest ..."
	./mach cppunittest
	local ret=$?
	if [[ ${ret} -ne 0 ]]; then
		eerror "Test suite cppunittest failed with error code ${ret}"
		failures+=( cppunittest )
	fi

	if [[ ${#failures} -eq 0 ]]; then
		einfo "Test suites succeeded"
	else
		die "Test suites failed: ${failures[@]}"
	fi
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
		"${BUILD_DIR}/dist/bin/xpcshell" \
		"${BUILD_DIR}/dist/bin/${PN}" \
		"${BUILD_DIR}/dist/bin/plugin-container"

	DESTDIR="${D}" ./mach install || die

	# Upstream cannot ship symlink but we can (bmo#658850)
	rm "${ED}${MOZILLA_FIVE_HOME}/${PN}-bin" || die
	dosym "${PN}" "${MOZILLA_FIVE_HOME}/${PN}-bin"

	# Don't install llvm-symbolizer from llvm-core/llvm package
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
	pref("spellchecker.dictionary_path", "${EPREFIX}/usr/share/myspell");
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
			pref("gfx.x11-egl.force-enabled", false);
			EOF
		else
			cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set hwaccel x11 prefs"
			pref("gfx.x11-egl.force-enabled", true);
			EOF
		fi

		# Install the vaapitest binary on supported arches (122.0 supports all platforms, bmo#1865969)
		exeinto "${MOZILLA_FIVE_HOME}"
		doexe "${BUILD_DIR}/dist/bin/vaapitest"

		# Install the v4l2test on supported arches (+ arm, + riscv64 when keyworded)
		if use arm64 ; then
			exeinto "${MOZILLA_FIVE_HOME}"
			doexe "${BUILD_DIR}/dist/bin/v4l2test"
		fi
	fi

	# Force the graphite pref if USE=system-harfbuzz is enabled, since the pref cannot disable it
	if use system-harfbuzz ; then
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set gfx.font_rendering.graphite.enabled pref"
		sticky_pref("gfx.font_rendering.graphite.enabled", true);
		EOF
	fi

	# Install language packs
	#dexlare -A suffix=( [amd64]="x86_64" [arm64]="arm" )
	local langpacks=( $(find "${BUILD_DIR}/dist/linux-${ELIBC//elibc_}-${MULTILIB_ABI_FLAG//abi_}/xpi" -type f -name '*.xpi') )
	if [[ -n "${langpacks}" ]] ; then
		moz_install_xpi "${MOZILLA_FIVE_HOME}/distribution/extensions" "${langpacks[@]}"
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
		"${WORKDIR}/${PN}.desktop-template" || die

	newmenu "${WORKDIR}/${PN}.desktop-template" "${desktop_filename}"

	rm "${WORKDIR}/${PN}.desktop-template" || die

	if use gnome-shell ; then
		# Install search provider for Gnome
		insinto /usr/share/gnome-shell/search-providers/
		doins browser/components/shell/search-provider-files/org.gnu.icecat.search-provider.ini

		insinto /usr/share/dbus-1/services/
		doins browser/components/shell/search-provider-files/org.gnu.icecat.SearchProvider.service

		# Make the dbus service aware of a previous session, bgo#939196
		sed -e \
			"s/Exec=\/usr\/bin\/icecat/Exec=\/usr\/$(get_libdir)\/icecat\/icecat --dbus-service \/usr\/bin\/icecat/g" \
			-i "${ED}/usr/share/dbus-1/services/org.gnu.icecat.SearchProvider.service" ||
				die "Failed to sed org.gnu.icecat.SearchProvider.service dbus file"

		# Update prefs to enable Gnome search provider
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to enable gnome-search-provider via prefs"
		pref("browser.gnome-search-provider.enabled", true);
		EOF
	fi

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
		"${ED}/usr/bin/${PN}-${ABI}" || die

	readme.gentoo_create_doc
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
}
