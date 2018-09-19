# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python2_7 )

CHROMIUM_LANGS="am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW"

inherit git-r3 check-reqs chromium-2 eutils gnome2-utils flag-o-matic multilib ninja-utils pax-utils portability python-any-r1 readme.gentoo-r1 toolchain-funcs xdg-utils versionator

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
SRC_URI="https://commondatastorage.googleapis.com/chromium-browser-official/${P}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="component-build cups gnome-keyring hangouts jumbo-build kerberos neon pic +proprietary-codecs pulseaudio selinux +suid +system-ffmpeg +system-icu +system-libvpx +tcmalloc widevine +thin-lto vaapi wayland X atk custom-cflags dbus gtk gtk3 doc"
RESTRICT="!system-ffmpeg? ( proprietary-codecs? ( bindist ) )"
REQUIRED_USE="atk? ( dbus )"

COMMON_DEPEND="
	app-arch/bzip2:=
	cups? ( >=net-print/cups-1.3.11:= )
	atk? ( 
		dev-libs/atk
		app-accessibility/at-spi2-atk:2
	)
	dev-libs/expat:=
	dev-libs/glib:2
	system-icu? ( >=dev-libs/icu-59:= )
	>=dev-libs/libxml2-2.9.5:=[icu]
	dev-libs/libxslt:=
	dev-libs/nspr:=
	>=dev-libs/nss-3.26:=
	>=dev-libs/re2-0.2016.05.01:=
	gnome-keyring? ( >=gnome-base/libgnome-keyring-3.12:= )
	>=media-libs/alsa-lib-1.0.19:=
	media-libs/fontconfig:=
	media-libs/freetype:=
	>=media-libs/harfbuzz-1.6.0:=[icu(-)]
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	system-libvpx? ( media-libs/libvpx:=[postproc,svc] )
	>=media-libs/openh264-1.6.0:=
	pulseaudio? ( media-sound/pulseaudio:= )
	system-ffmpeg? (
		>=media-video/ffmpeg-4:=
		|| (
			media-video/ffmpeg[-samba]
			>=net-fs/samba-4.5.10-r1[-debug(-)]
		)
		!=net-fs/samba-4.5.12-r0
		media-libs/opus:=
	)
	dbus? ( sys-apps/dbus:= )
	sys-apps/pciutils:=
	virtual/udev
	x11-libs/cairo:=
	x11-libs/gdk-pixbuf:2
	gtk3? ( x11-libs/gtk+:3[X] )
	gtk? ( x11-libs/gtk+:2[X] )
	X? ( 
		x11-libs/gtk+:3[X]
		x11-libs/libX11:=
		x11-libs/libXcomposite:=
		x11-libs/libXcursor:=
		x11-libs/libXdamage:=
		x11-libs/libXext:=
		x11-libs/libXfixes:=
		>=x11-libs/libXi-1.6.0:=
		x11-libs/libXrandr:=
		x11-libs/libXrender:=
		x11-libs/libXScrnSaver:=
		x11-libs/libXtst:=
		x11-libs/pango:=
	)
	app-arch/snappy:=
	media-libs/flac:=
	>=media-libs/libwebp-0.4.0:=
	sys-libs/zlib:=[minizip]
	kerberos? ( virtual/krb5 )
	wayland? ( 
		>=dev-libs/wayland-1.9
		>=dev-libs/wayland-protocols-1.9
	)
"
# For nvidia-drivers blocker, see bug #413637 .
RDEPEND="${COMMON_DEPEND}
	!<www-plugins/chrome-binary-plugins-57
	x11-misc/xdg-utils
	virtual/opengl
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-chromium )
	tcmalloc? ( !<x11-drivers/nvidia-drivers-331.20 )
	widevine? ( www-plugins/chrome-binary-plugins[widevine(-)] )
"
# dev-vcs/git - https://bugs.gentoo.org/593476
# sys-apps/sandbox - https://crbug.com/586444
DEPEND="${COMMON_DEPEND}
	>=app-arch/gzip-1.7
	!arm? (
		dev-lang/yasm
	)
	dev-lang/perl
	dev-util/gn
	>=dev-util/gperf-3.0.3
	>=dev-util/ninja-1.7.2
	>=net-libs/nodejs-6.9.4
	sys-apps/hwids[usb(+)]
	>=sys-devel/bison-2.4.3
	sys-devel/flex
	>=sys-devel/clang-5
	>=sys-devel/lld-5
	virtual/pkgconfig
	dev-vcs/git
"

if ! has chromium_pkg_die ${EBUILD_DEATH_HOOKS}; then
	EBUILD_DEATH_HOOKS+=" chromium_pkg_die";
fi

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
Some web pages may require additional fonts to display properly.
Try installing some of the following packages if some characters
are not displayed properly:
- media-fonts/arphicfonts
- media-fonts/droid
- media-fonts/ipamonafont
- media-fonts/noto
- media-fonts/ja-ipafonts
- media-fonts/takao-fonts
- media-fonts/wqy-microhei
- media-fonts/wqy-zenhei

To fix broken icons on the Downloads page, you should install an icon
theme that covers the appropriate MIME types, and configure this as your
GTK+ icon theme.
"

PATCHES=(
	"${FILESDIR}/chromium-compiler-r4.patch"
	"${FILESDIR}/chromium-webrtc-r0.patch"
	"${FILESDIR}/chromium-memcpy-r0.patch"
	"${FILESDIR}/chromium-math.h-r0.patch"
	"${FILESDIR}/chromium-stdint.patch"
	"${FILESDIR}/chromium-ffmpeg-ebp-r1.patch"
	"${FILESDIR}/chromium-skia-harmony.patch"
	"${FILESDIR}/chromium-system-icu.patch"
)

pre_build_checks() {
	#if [[ ${MERGE_TYPE} != binary ]]; then
	#	local -x CPP="$(tc-getCXX) -E"
	#	if tc-is-clang && ! version_is_at_least "3.9.1" "$(clang-fullversion)"; then
	#		# bugs: #601654
	#		die "At least clang 3.9.1 is required"
	#	fi
	#	if tc-is-gcc && ! version_is_at_least 5.0 "$(gcc-version)"; then
	#		# bugs: #535730, #525374, #518668, #600288, #627356
	#		die "At least gcc 5.0 is required"
	#	fi
	#fi

	# Check build requirements, bug #541816 and bug #471810 .
	CHECKREQS_MEMORY="3G"
	CHECKREQS_DISK_BUILD="5G"
	eshopts_push -s extglob
	if is-flagq '-g?(gdb)?([1-9])'; then
		CHECKREQS_DISK_BUILD="25G"
		if ! use component-build; then
			CHECKREQS_MEMORY="16G"
		fi
	fi
	eshopts_pop
	check-reqs_pkg_setup
}

pkg_pretend() {
	pre_build_checks
}

pkg_setup() {
	pre_build_checks

	chromium_suid_sandbox_check_kernel_config
}

S="${WORKDIR}/src" 
src_unpack() {
	# build tools
	
	URI_DEPOT_TOOLS="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
	einfo "Fetching depot_tools from googlesource"
	git-r3_fetch ${URI_DEPOT_TOOLS}
	git-r3_checkout ${URI_DEPOT_TOOLS} depot_tools

	#EGIT_REPO_URI="git://github.com/Igalia/chromium.git"
	#EGIT_BRANCH="ozone-wayland-dev"
	einfo "Fetching chromium using depot_tools"
	export GYP_DEFINES="OS=linux"
	#"${EPYTHON}" 
	python2 depot_tools/gclient.py config --spec 'solutions=[{\
		"url": "https://github.com/Igalia/chromium.git@origin/ozone-wayland-dev",\
		"managed": False,\
		"name": "src",\
		"deps_file": "DEPS",\
		"custom_deps": {\
			"src/build/third_party/cbuildbot_chromite": None,\
			"src/build/third_party/gsutil": None,\
			"src/build/third_party/lighttpd": None,\
			"src/build/third_party/swarm_client": None,\
			"src/build/third_party/xvfb": None,\
			"src/build/xvfb": None,\
			"src/chrome/tools/test/reference_build/chrome_linux": None,\
			"src/chrome/tools/test/reference_build/chrome_mac": None,\
			"src/chrome/tools/test/reference_build/chrome_win": None,\
			"src/chrome/tools/test/reference_build/chrome": None,\
			"src/chrome/test/data/perf/canvas_bench": None,\
			"src/chrome/test/data/perf/frame_rate/content": None,\
			"src/chrome/installer/mac/third_party/xz/xz": None,\
			"src/third_party/WebKit/LayoutTests": None,\
			"src/webkit/data/layout_tests/LayoutTests":None,\
			"src/third_party/hunspell_dictionaries": None,\
			"src/third_party/chromite": None,\
			"src/third_party/pyelftools": None,\
			"src/third_party/GTM": None,\
			"src/third_party/pdfsqueeze": None,\
			"src/third_party/swig/mac": None,\
			"src/third_party/ffmpeg": None,\
			"src/third_party/WebKit/Tools/gdb": None,\
			"src/chrome/test/data/layout_tests/LayoutTests/platform/chromium-mac/http/tests/workers": None,\
			"chromeos": None,\
			"src/third_party/cros": None,\
			"devices": None,\
			"src/android_webview": None\
	}}]; target_os = ["linux"]; target_os_only = True' || die
	
	#"${EPYTHON}" 
	python2 depot_tools/gclient.py sync --upstream --no-history --shallow --with_branch_heads --jobs=1 --disable-syntax-validation --nohooks --noprehooks || die
} 


src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	default

	use widevine && eapply "${FILESDIR}/${PN}-widevine-r2.patch"
	use vaapi && for i in $(cat "${FILESDIR}/vaapi-patchset-$(get_major_version)/series");do eapply "${FILESDIR}/vaapi-patchset-$(get_major_version)/$i";done
	for i in $(cat "${FILESDIR}/debian-patchset-$(get_major_version)/series");do eapply "${FILESDIR}/debian-patchset-$(get_major_version)/$i";done
	for i in $(cat "${FILESDIR}/ungoogled-patchset-$(get_major_version)/series");do eapply "${FILESDIR}/ungoogled-patchset-$(get_major_version)/$i";done


	mkdir -p third_party/node/linux/node-linux-x64/bin || die
	ln -s "${EPREFIX}"/usr/bin/node third_party/node/linux/node-linux-x64/bin/node || die

	local keeplibs=(
		base/third_party/dmg_fp
		base/third_party/dynamic_annotations
		base/third_party/icu
		base/third_party/nspr
		base/third_party/superfasthash
		base/third_party/symbolize
		base/third_party/valgrind
		base/third_party/xdg_mime
		base/third_party/xdg_user_dirs
		buildtools/third_party/libc++
		buildtools/third_party/libc++abi
		chrome/third_party/mozilla_security_manager
		courgette/third_party
		net/third_party/http2
		net/third_party/mozilla_security_manager
		net/third_party/nss
		net/third_party/quic
		net/third_party/spdy
		third_party/WebKit
		third_party/abseil-cpp
		third_party/analytics
		third_party/angle
		third_party/angle/src/common/third_party/base
		third_party/angle/src/common/third_party/smhasher
		third_party/angle/src/third_party/compiler
		third_party/angle/src/third_party/libXNVCtrl
		third_party/angle/src/third_party/trace_event
		third_party/angle/third_party/glslang
		third_party/angle/third_party/spirv-headers
		third_party/angle/third_party/spirv-tools
		third_party/angle/third_party/vulkan-headers
		third_party/angle/third_party/vulkan-loader
		third_party/angle/third_party/vulkan-tools
		third_party/angle/third_party/vulkan-validation-layers
		third_party/apple_apsl
		third_party/blink
		third_party/boringssl
		third_party/boringssl/src/third_party/fiat
		third_party/breakpad
		third_party/breakpad/breakpad/src/third_party/curl
		third_party/brotli
		third_party/cacheinvalidation
		third_party/catapult
		third_party/catapult/common/py_vulcanize/third_party/rcssmin
		third_party/catapult/common/py_vulcanize/third_party/rjsmin
		third_party/catapult/third_party/beautifulsoup4
		third_party/catapult/third_party/html5lib-python
		third_party/catapult/third_party/polymer
		third_party/catapult/third_party/six
		third_party/catapult/tracing/third_party/d3
		third_party/catapult/tracing/third_party/gl-matrix
		third_party/catapult/tracing/third_party/jszip
		third_party/catapult/tracing/third_party/mannwhitneyu
		third_party/catapult/tracing/third_party/oboe
		third_party/catapult/tracing/third_party/pako
		third_party/ced
		third_party/cld_3
		third_party/crashpad
		third_party/crashpad/crashpad/third_party/zlib
		third_party/crc32c
		third_party/cros_system_api
		third_party/devscripts
		third_party/dom_distiller_js
		third_party/fips181
		third_party/flatbuffers
		third_party/flot
		third_party/freetype
		third_party/glslang-angle
		third_party/google_input_tools
		third_party/google_input_tools/third_party/closure_library
		third_party/google_input_tools/third_party/closure_library/third_party/closure
		third_party/googletest
		third_party/hunspell
		third_party/iccjpeg
		third_party/inspector_protocol
		third_party/jinja2
		third_party/jstemplate
		third_party/khronos
		third_party/leveldatabase
		third_party/libXNVCtrl
		third_party/libaddressinput
		third_party/libaom
		third_party/libjingle
		third_party/libphonenumber
		third_party/libsecret
		third_party/libsrtp
		third_party/libsync
		third_party/libudev
		third_party/libwebm
		third_party/libxml/chromium
		third_party/libyuv
		third_party/llvm
		third_party/lss
		third_party/lzma_sdk
		third_party/markupsafe
		third_party/mesa
		third_party/metrics_proto
		third_party/modp_b64
		third_party/node
		third_party/node/node_modules/polymer-bundler/lib/third_party/UglifyJS2
		third_party/openmax_dl
		third_party/ots
		third_party/pdfium
		third_party/pdfium/third_party/agg23
		third_party/pdfium/third_party/base
		third_party/pdfium/third_party/bigint
		third_party/pdfium/third_party/freetype
		third_party/pdfium/third_party/lcms
		third_party/pdfium/third_party/libopenjpeg20
		third_party/pdfium/third_party/libpng16
		third_party/pdfium/third_party/libtiff
		third_party/pdfium/third_party/skia_shared
		third_party/perfetto
		third_party/ply
		third_party/polymer
		third_party/protobuf
		third_party/protobuf/third_party/six
		third_party/pyjson5
		third_party/qcms
		third_party/rnnoise
		third_party/s2cellid
		third_party/sfntly
		third_party/simplejson
		third_party/skia
		third_party/skia/third_party/gif
		third_party/skia/third_party/skcms
		third_party/skia/third_party/vulkan
		third_party/smhasher
		third_party/spirv-headers
		third_party/spirv-tools-angle
		third_party/sqlite
		third_party/unrar
		third_party/usrsctp
		third_party/vulkan
		third_party/vulkan-validation-layers
		third_party/wayland
		third_party/wayland-protocols
		third_party/web-animations-js
		third_party/webdriver
		third_party/webrtc
		third_party/widevine
		third_party/woff2
		third_party/zlib/google
		url/third_party/mozilla
		v8/src/third_party/valgrind
		v8/src/third_party/utf8-decoder
		v8/third_party/antlr4
		v8/third_party/inspector_protocol

		# gyp -> gn leftovers
		base/third_party/libevent
		third_party/adobe
		third_party/speech-dispatcher
		third_party/usb_ids
		third_party/xdg-utils
		third_party/yasm/run_yasm.py
	)
	if ! use system-ffmpeg; then
		keeplibs+=( third_party/ffmpeg third_party/opus )
	fi
	if ! use system-icu; then
		keeplibs+=( third_party/icu )
	fi
	if ! use system-libvpx; then
		keeplibs+=( third_party/libvpx )
		keeplibs+=( third_party/libvpx/source/libvpx/third_party/x86inc )
	fi
	if use tcmalloc; then
		keeplibs+=( third_party/tcmalloc )
	fi
	keeplibs+=( third_party/ungoogled )

	# Remove most bundled libraries. Some are still needed.
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove || die
}

src_configure() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	local myconf_gn=""

	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX NM

	if ! tc-is-clang; then
		# Force clang since gcc is pretty broken at the moment.
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		strip-unsupported-flags
	fi

	if tc-is-clang; then
		myconf_gn+=" is_clang=true clang_use_chrome_plugins=false"
	else
		myconf_gn+=" is_clang=false"
	fi

	# Define a custom toolchain for GN
	myconf_gn+=" custom_toolchain=\"//build/toolchain/linux/unbundle:default\""

	if tc-is-cross-compiler; then
		tc-export BUILD_{AR,CC,CXX,NM}
		myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:host\""
		myconf_gn+=" v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\""
	else
		myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:default\""
	fi

	# GN needs explicit config for Debug/Release as opposed to inferring it from build directory.
	myconf_gn+=" is_debug=false"

	# Component build isn't generally intended for use by end users. It's mostly useful
	# for development and debugging.
	myconf_gn+=" is_component_build=$(usex component-build true false)"

	# https://chromium.googlesource.com/chromium/src/+/lkcr/docs/jumbo.md
	myconf_gn+=" use_jumbo_build=$(usex jumbo-build true false)"

	myconf_gn+=" use_allocator=$(usex tcmalloc \"tcmalloc\" \"none\")"

	# Disable nacl, we can't build without pnacl (http://crbug.com/269560).
	myconf_gn+=" enable_nacl=false"

	# Use system-provided libraries.
	# TODO: freetype -- remove sources (https://bugs.chromium.org/p/pdfium/issues/detail?id=733).
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_libsrtp (bug #459932).
	# TODO: use_system_protobuf (bug #525560).
	# TODO: use_system_ssl (http://crbug.com/58087).
	# TODO: use_system_sqlite (http://crbug.com/22208).

	#
	myconf_gn+=" use_gio=false"
	myconf_gn+=" use_vaapi=$(usex vaapi true false)"
	myconf_gn+=" enable_vulkan=true"

	# Debian
	myconf_gn+=" use_libjpeg_turbo=true"
	myconf_gn+=" enable_swiftshader=false"
	myconf_gn+=" enable_nacl_nonsfi=false"
	myconf_gn+=" enable_google_now=false"
	myconf_gn+=" enable_reading_list=false"
	myconf_gn+=" enable_iterator_debugging=false"
	myconf_gn+=" link_pulseaudio=true"
	myconf_gn+=" use_system_zlib=true"
	myconf_gn+=" use_system_lcms2=true"
	myconf_gn+=" use_system_libjpeg=true"
	myconf_gn+=" use_system_freetype=true"

	#
	myconf_gn+=" blink_symbol_level=0"
	myconf_gn+=" enable_ac3_eac3_audio_demuxing=true"
	myconf_gn+=" enable_hevc_demuxing=true"
	myconf_gn+=" enable_mdns=false"
	myconf_gn+=" enable_mse_mpeg2ts_stream_parser=true"
	myconf_gn+=" enable_one_click_signin=false"
	myconf_gn+=" enable_remoting=false"
	myconf_gn+=" enable_reporting=false"
	myconf_gn+=" enable_service_discovery=false"
	myconf_gn+=" exclude_unwind_tables=true"
	myconf_gn+=" safe_browsing_mode=0"
	myconf_gn+=" symbol_level=0"
	myconf_gn+=" use_sysroot=false"

	# wayland
	if use wayland; then
		myconf_gn+=" use_ozone=true"
		myconf_gn+=" ozone_auto_platforms=false"
		myconf_gn+=" ozone_platform_x11=false ozone_platform_wayland=true"
		myconf_gn+=" enable_package_mash_services=true"
		myconf_gn+=" enable_xdg_shell=true xkbcommon=true"
		myconf_gn+=" enable_mus=true"
	fi


	# libevent: https://bugs.gentoo.org/593458
	local gn_system_libraries=(
		flac
		fontconfig
		freetype
		# Need harfbuzz_from_pkgconfig target
		harfbuzz-ng
		libdrm
		libjpeg
		libpng
		libwebp
		libxml
		libxslt
		openh264
		re2
		snappy
		yasm
		zlib
	)
	if use system-ffmpeg; then
		gn_system_libraries+=( ffmpeg opus )
	fi
	if use system-icu; then
		gn_system_libraries+=( icu )
	fi
	if use system-libvpx; then
		gn_system_libraries+=( libvpx )
	fi
	gn_system_libraries+=( libevent )

	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" || die

	# See dependency logic in third_party/BUILD.gn
	myconf_gn+=" use_system_harfbuzz=true"

	# Optional dependencies.
	myconf_gn+=" enable_hangout_services_extension=$(usex hangouts true false)"
	myconf_gn+=" enable_widevine=$(usex widevine true false)"
	myconf_gn+=" use_cups=$(usex cups true false)"
	myconf_gn+=" use_gnome_keyring=$(usex gnome-keyring true false)"
	myconf_gn+=" use_kerberos=$(usex kerberos true false)"
	myconf_gn+=" use_pulseaudio=$(usex pulseaudio true false)"

	# TODO: link_pulseaudio=true for GN.

	myconf_gn+=" fieldtrial_testing_like_official_build=true"

	# Never use bundled gold binary. Disable gold linker flags for now.
	# Do not use bundled clang.
	# Trying to use gold results in linker crash.
	myconf_gn+=" use_gold=true use_sysroot=false linux_use_bundled_binutils=false use_custom_libcxx=false"

	# Disable forced lld, bug 641556
	myconf_gn+=" use_lld=true"

	ffmpeg_branding="$(usex proprietary-codecs Chrome Chromium)"
	myconf_gn+=" proprietary_codecs=$(usex proprietary-codecs true false)"
	myconf_gn+=" ffmpeg_branding=\"${ffmpeg_branding}\""

	# Set up Google API keys, see http://www.chromium.org/developers/how-tos/api-keys .
	# Note: these are for Gentoo use ONLY. For your own distribution,
	# please get your own set of keys. Feel free to contact chromium@gentoo.org
	# for more info.
	local google_api_key="AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc"
	local google_default_client_id="329227923882.apps.googleusercontent.com"
	local google_default_client_secret="vgKG0NNv7GoDpbtoFNLxCUXu"
	myconf_gn+=" google_api_key=\"${google_api_key}\""
	myconf_gn+=" google_default_client_id=\"${google_default_client_id}\""
	myconf_gn+=" google_default_client_secret=\"${google_default_client_secret}\""

	local myarch="$(tc-arch)"
	if [[ $myarch = amd64 ]] ; then
		myconf_gn+=" target_cpu=\"x64\""
		ffmpeg_target_arch=x64
	elif [[ $myarch = x86 ]] ; then
		myconf_gn+=" target_cpu=\"x86\""
		ffmpeg_target_arch=ia32
	elif [[ $myarch = arm64 ]] ; then
		myconf_gn+=" target_cpu=\"arm64\""
		ffmpeg_target_arch=arm64
	elif [[ $myarch = arm ]] ; then
		myconf_gn+=" target_cpu=\"arm\""
		ffmpeg_target_arch=$(usex neon arm-neon arm)
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	# Make sure that -Werror doesn't get added to CFLAGS by the build system.
	# Depending on GCC version the warnings are different and we don't want
	# the build to fail because of that.
	myconf_gn+=" treat_warnings_as_errors=false"

	# Disable fatal linker warnings, bug 506268.
	myconf_gn+=" fatal_linker_warnings=false"

	# Avoid CFLAGS problems, bug #352457, bug #390147.
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		# Prevent linker from running out of address space, bug #471810 .
		if use x86; then
			filter-flags "-g*"
		fi

		# Prevent libvpx build failures. Bug 530248, 544702, 546984.
		if [[ ${myarch} == amd64 || ${myarch} == x86 ]]; then
			filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2
		fi
	fi

	# https://bugs.gentoo.org/588596
	#append-cxxflags $(test-flags-CXX -fno-delete-null-pointer-checks)

	# Bug 491582.
	export TMPDIR="${WORKDIR}/temp"
	mkdir -p -m 755 "${TMPDIR}" || die

	# https://bugs.gentoo.org/654216
	addpredict /dev/dri/ #nowarn

	if ! use system-ffmpeg; then
		local build_ffmpeg_args=""
		if use pic && [[ "${ffmpeg_target_arch}" == "ia32" ]]; then
			build_ffmpeg_args+=" --disable-asm"
		fi

		if use vaapi; then
			build_ffmpeg_args+=" --enable-vaapi --enable-vaapi" build_ffmpeg_args+=" --enable-vaapi --enable-vaapi --optflags=-O3,-pipe,-fomit-frame-pointer,-fno-stack-protector --disable-debug"
		else
			build_ffmpeg_args+=" --enable-vdpau --enable-vdpau --enable-hwaccel=h264_vdpau,hevc_vdpau,mpeg1_vdpau,mpeg2_vdpau,mpeg4_vdpau,vc1_vdpau,wmv3_vdpau --optflags=-O3,-pipe,-fomit-frame-pointer,-fno-stack-protector --disable-debug"
		fi

		# Re-configure bundled ffmpeg. See bug #491378 for example reasons.
		einfo "Configuring bundled ffmpeg..."
		pushd third_party/ffmpeg > /dev/null || die
		chromium/scripts/build_ffmpeg.py linux ${ffmpeg_target_arch} \
			--branding ${ffmpeg_branding} -- ${build_ffmpeg_args} || die
		chromium/scripts/copy_config.sh || die
		chromium/scripts/generate_gn.py || die
		popd > /dev/null || die
	fi

	einfo "Configuring Chromium..."
	set -- gn gen --args="${myconf_gn} ${EXTRA_GN}" out/Release
	echo "$@"
	"$@" || die
}

src_compile() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	#"${EPYTHON}" tools/clang/scripts/update.py --force-local-build --gcc-toolchain /usr --skip-checkout --use-system-cmake --without-android || die

	# Build mksnapshot and pax-mark it.
	local x
	for x in mksnapshot v8_context_snapshot_generator; do
		if tc-is-cross-compiler; then
			eninja -C out/Release "host/${x}"
			pax-mark m "out/Release/host/${x}"
		else
			eninja -C out/Release "${x}"
			pax-mark m "out/Release/${x}"
		fi
	done

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason.
	eninja -C out/Release chrome chromedriver
	use suid && eninja -C out/Release chrome_sandbox

	pax-mark m out/Release/chrome
}

src_install() {
	local CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome

	if use suid; then
		newexe out/Release/chrome_sandbox chrome-sandbox
		fperms 4755 "${CHROMIUM_HOME}/chrome-sandbox"
	fi

	doexe out/Release/chromedriver

	local sedargs=( -e "s:/usr/lib/:/usr/$(get_libdir)/:g" )
	sed "${sedargs[@]}" "${FILESDIR}/chromium-launcher-r3.sh" > chromium-launcher.sh || die
	doexe chromium-launcher.sh

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it; bug #355517.
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	dosym "${CHROMIUM_HOME}/chromedriver" /usr/bin/chromedriver

	# Allow users to override command-line options, bug #357629.
	insinto /etc/chromium
	newins "${FILESDIR}/chromium.default" "default"

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd

	insinto "${CHROMIUM_HOME}"
	doins out/Release/*.bin
	doins out/Release/*.pak
	doins out/Release/*.so

	if ! use system-icu; then
		doins out/Release/icudtl.dat
	fi

	doins -r out/Release/locales
	doins -r out/Release/resources

	# Install icons and desktop entry.
	local branding size
	for size in 16 22 24 32 48 64 128 256 ; do
		case ${size} in
			16|32) branding="chrome/app/theme/default_100_percent/chromium" ;;
				*) branding="chrome/app/theme/chromium" ;;
		esac
		newicon -s ${size} "${branding}/product_logo_${size}.png" \
			chromium-browser.png
	done

	if use gnome; then
		local mime_types="text/html;text/xml;application/xhtml+xml;"
		mime_types+="x-scheme-handler/http;x-scheme-handler/https;" # bug #360797
		mime_types+="x-scheme-handler/ftp;" # bug #412185
		mime_types+="x-scheme-handler/mailto;x-scheme-handler/webcal;" # bug #416393
		make_desktop_entry \
			chromium-browser \
			"Chromium" \
			chromium-browser \
			"Network;WebBrowser" \
			"MimeType=${mime_types}\nStartupWMClass=chromium-browser"
		sed -e "/^Exec/s/$/ %U/" -i "${ED}"/usr/share/applications/*.desktop || die

		# Install GNOME default application entry (bug #303100).
		insinto /usr/share/gnome-control-center/default-apps
		newins "${FILESDIR}"/chromium-browser.xml chromium-browser.xml
	fi

	if use doc; then
		readme.gentoo_create_doc
	fi
}

pkg_preinst() {
	if use gnome; then
		gnome2_icon_savelist
	fi
}

pkg_postrm() {
	if use gnome; then
		gnome2_icon_cache_update
		xdg_desktop_database_update
	fi
}

pkg_postinst() {
	if use gnome; then
		gnome2_icon_cache_update
		xdg_desktop_database_update
		readme.gentoo_print_elog
	fi
}
