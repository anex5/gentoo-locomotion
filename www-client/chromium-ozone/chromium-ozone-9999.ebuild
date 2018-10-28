# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_{5,6,7}} )

CHROMIUM_LANGS="
	am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he hi hr hu id
	it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw ta te
	th tr uk vi zh-CN zh-TW
"

inherit git-r3 check-reqs chromium-2 gnome2-utils eapi7-ver flag-o-matic multilib ninja-utils pax-utils portability python-r1 readme.gentoo-r1 toolchain-funcs xdg-utils

UGC_PV="69.0.3497.100-2"
UGC_P="ungoogled-chromium-${UGC_PV}"
UGC_WD="${WORKDIR}/${UGC_P}"


DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://github.com/Eloston/ungoogled-chromium https://www.chromium.org/ https://github.com/Igalia/chromium"
SRC_URI="
	https://github.com/Eloston/ungoogled-chromium/archive/${UGC_PV}.tar.gz -> ${UGC_P}.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="component-build cups custom-cflags gnome-keyring jumbo-build kerberos openh264 +proprietary-codecs pulseaudio selinux +suid +system-ffmpeg +system-icu +system-libevent +system-libvpx +tcmalloc vaapi widevine wayland X atk dbus gtk doc"
RESTRICT="!system-ffmpeg? ( proprietary-codecs? ( bindist ) )"

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
	system-libevent? ( dev-libs/libevent )
	>=dev-libs/libxml2-2.9.4-r3:=[icu]
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
	system-libvpx? ( >=media-libs/libvpx-1.7.0:=[postproc,svc] )
	openh264? ( >=media-libs/openh264-1.6.0:= )
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
	vaapi? ( >=x11-libs/libva-2.1.0:= )

	gtk? ( x11-libs/gtk+:3[X] )
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
"
# For nvidia-drivers blocker (Bug #413637)
RDEPEND="${COMMON_DEPEND}
	x11-misc/xdg-utils
	virtual/opengl
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-chromium )
	tcmalloc? ( !<x11-drivers/nvidia-drivers-331.20 )
	!x86? (
		widevine? ( www-plugins/chrome-binary-plugins[widevine(-)] )
	)
	!www-client/chromium
	!www-client/ungoogled-chromium-bin
"
# dev-vcs/git (Bug #593476)
# sys-apps/sandbox - https://crbug.com/586444
DEPEND="${COMMON_DEPEND}
	>=app-arch/gzip-1.7
	dev-lang/perl
	dev-lang/yasm
	dev-util/gn
	>=dev-util/gperf-3.0.3
	>=dev-util/ninja-1.7.2
	>=net-libs/nodejs-6.9.4
	sys-apps/hwids[usb(+)]
	>=sys-devel/bison-2.4.3
	>=sys-devel/clang-6
	sys-devel/flex
	>=sys-devel/lld-6
	>=sys-devel/llvm-6
	virtual/pkgconfig
	dev-vcs/git
"

REQUIRED_USE="
	|| ( $(python_gen_useflags 'python3*') )
	|| ( $(python_gen_useflags 'python2*') )
"

# shellcheck disable=SC2086
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

PATCHES=()
#	"${FILESDIR}/chromium-compiler-r4.patch"
#	"${FILESDIR}/chromium-webrtc-r0.patch"
#	"${FILESDIR}/chromium-memcpy-r0.patch"
#	"${FILESDIR}/chromium-math.h-r0.patch"
#	"${FILESDIR}/chromium-stdint.patch"
#	"${FILESDIR}/chromium-ffmpeg-ebp-r1.patch"
#)


pre_build_checks() {
	# Check build requirements (Bug #541816, #471810)
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

src_unpack() {

	default
	
	# build tools  
	
	URI_DEPOT_TOOLS="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
	einfo "Fetching depot_tools from googlesource"
	git-r3_fetch ${URI_DEPOT_TOOLS}
	git-r3_checkout ${URI_DEPOT_TOOLS} depot_tools

	dosym {$S}/depot_tools/cipd /usr/bin/cipd
	dosym {$S}/depot_tools/gclient /usr/bin/gclient

	einfo "Fetching chromium using depot_tools"
	
	S="${WORKDIR}/src"

	python_setup 'python2*'

	if ! [[ -f .gclient ]]; then
		depot_tools/gclient config --name=src --spec 'solutions=[{\
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
			"src/third_party/WebKit/Tools/gdb": None,\
			"src/chrome/test/data/layout_tests/LayoutTests/platform/chromium-mac/http/tests/workers": None,\
			"chromeos": None,\
			"src/third_party/cros": None \
		}}]; target_os = ["linux"]; target_os_only = True' || die
	fi

	depot_tools/gclient sync --upstream --no-history --shallow --with_branch_heads --jobs=1 --disable-syntax-validation || die
	#depot_tools/gclient runhooks || die
	
} 

src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
    	
	python_setup

	default

	mkdir -p third_party/node/linux/node-linux-x64/bin || die
	ln -sf "${EPREFIX%/}"/usr/bin/node third_party/node/linux/node-linux-x64/bin/node || die

	# Apply extra patches
	#local ep
	#for ep in "${FILESDIR}/extra\-69/*.patch"; do
	#	eapply "${ep}"
	#done

	# Adapt ungoogled-chromium to *Gentoo* way
	local ugc_cli="${UGC_WD}/run_buildkit_cli.py"
	local ugc_config="${UGC_WD}/config_bundles/archlinux"
	local ugc_common_dir="${UGC_WD}/config_bundles/common"
	local ugc_rooted_dir="${UGC_WD}/config_bundles/linux_rooted"

	# Remove redundant patch and remove arm/gcc patches
	sed -i \
		-e '/chromium-clang-compiler-flags.patch/d' \
		-e '/arm\/skia.patch/d' \
		-e '/arm\/gcc_skcms_ice.patch/d' \
		"${ugc_common_dir}/patch_order.list" || die
	sed -i \
		-e '/icu.patch/d' \
		"${ugc_rooted_dir}/patch_order.list" || die

	if ! use system-icu; then
		sed -i '/common\/icudtl.dat/d' \
			"${ugc_rooted_dir}/pruning.list" || die
	fi

	if ! use system-libevent; then
		sed -i '/system\/event.patch/d' \
			"${ugc_rooted_dir}/patch_order.list" || die
	fi

	if ! use system-libvpx; then
		sed -i '/system\/vpx.patch/d' \
			"${ugc_rooted_dir}/patch_order.list" || die
	fi

	if ! use widevine; then
		sed -i '/widevine/d' \
			"${ugc_common_dir}/patch_order.list" || die
	fi

	if ! use vaapi; then
		sed -i '/patchset\/chromium-vaapi-r18.patch/d' \
			"${ugc_rooted_dir}/patch_order.list" || die
	fi

	python_setup 'python3*'

	ebegin "Pruning binaries"
	"${ugc_cli}" prune -b "${ugc_config}" "${S}" #|| die
	eend $?

	ebegin "Applying ungoogled-chromium patches"
	"${ugc_cli}" patches apply -b "${ugc_config}" "${S}" #|| die
	eend $?

	ebegin "Applying domain substitution"
	"${ugc_cli}" domains apply -b "${ugc_config}" -c domainsubcache.tar.gz "${S}" #|| die
	eend $?

	local keeplibs=(
		base/third_party/dmg_fp
		base/third_party/dynamic_annotations
		base/third_party/icu
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
		#third_party/cros_system_api
		third_party/devscripts
		third_party/dom_distiller_js
		third_party/fips181
		third_party/flatbuffers
		third_party/flot
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
		#third_party/lss
		third_party/lzma_sdk
		third_party/markupsafe
		third_party/mesa
		third_party/metrics_proto
		third_party/modp_b64
		third_party/node
		#third_party/node/node_modules/polymer-bundler/lib/third_party/UglifyJS2
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
		#third_party/ungoogled
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
		#v8/third_party/antlr4
		v8/third_party/inspector_protocol

		# gyp -> gn leftovers
		third_party/adobe
		third_party/speech-dispatcher
		third_party/usb_ids
		third_party/xdg-utils
		third_party/yasm/run_yasm.py
	)
	if ! use openh264; then
		keeplibs+=( third_party/openh264 )
	fi
	if ! use system-ffmpeg; then
		keeplibs+=( third_party/ffmpeg third_party/opus )
	fi
	if ! use system-icu; then
		keeplibs+=( third_party/icu )
	fi
	if ! use system-libevent; then
		keeplibs+=( base/third_party/libevent )
	fi
	if ! use system-libvpx; then
		keeplibs+=( third_party/libvpx )
		keeplibs+=( third_party/libvpx/source/libvpx/third_party/x86inc )
	fi
	if use tcmalloc; then
		keeplibs+=( third_party/tcmalloc )
	fi

	python_setup 'python2*'

	# Remove most bundled libraries, some are still needed
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove || die
}

src_configure() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python2*'

	local myconf_gn=""

	# Make sure the build system will use the right tools (Bug #340795)
	tc-export AR CC CXX NM

	# Force clang
	CC=${CHOST}-clang
	CXX=${CHOST}-clang++
	AR=llvm-ar
	NM=llvm-nm
	strip-unsupported-flags

	# Use system-provided libraries
	# TODO: freetype -- remove sources (https://bugs.chromium.org/p/pdfium/issues/detail?id=733)
	# TODO: use_system_hunspell (upstream changes needed)
	# TODO: use_system_libsrtp (Bug #459932)
	# TODO: use_system_protobuf (Bug #525560)
	# TODO: use_system_ssl (http://crbug.com/58087)
	# TODO: use_system_sqlite (http://crbug.com/22208)

	local gn_system_libraries=(
		flac
		fontconfig
		freetype
		harfbuzz-ng
		libdrm
		libjpeg
		libpng
		libwebp
		libxml
		libxslt
		re2
		snappy
		yasm
		zlib
	)
	if use openh264; then
		gn_system_libraries+=( openh264 )
	fi
	if use system-ffmpeg; then
		gn_system_libraries+=( ffmpeg opus )
	fi
	if use system-icu; then
		gn_system_libraries+=( icu )
	fi
	if use system-libevent; then
		gn_system_libraries+=( libevent )
	fi
	if use system-libvpx; then
		gn_system_libraries+=( libvpx )
	fi

	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" || die

	ffmpeg_branding="$(usex proprietary-codecs Chrome Chromium)"

	# Component build isn't generally intended for use by end users.
	# It's mostly useful for development and debugging.
	myconf_gn+=" is_component_build=$(usex component-build true false)"

	# Keep in sync with config_bundles/common/gn_flags.map
	myconf_gn+=" blink_symbol_level=0"
	myconf_gn+=" clang_use_chrome_plugins=false"
	myconf_gn+=" enable_ac3_eac3_audio_demuxing=true"
	myconf_gn+=" enable_google_now=false"
	myconf_gn+=" enable_hangout_services_extension=false"
	myconf_gn+=" enable_hevc_demuxing=true"
	myconf_gn+=" enable_iterator_debugging=false"
	myconf_gn+=" enable_mdns=false"
	myconf_gn+=" enable_mse_mpeg2ts_stream_parser=true"
	myconf_gn+=" enable_nacl=false"
	myconf_gn+=" enable_nacl_nonsfi=false"
	myconf_gn+=" enable_one_click_signin=false"
	myconf_gn+=" enable_reading_list=false"
	myconf_gn+=" enable_remoting=false"
	myconf_gn+=" enable_reporting=false"
	myconf_gn+=" enable_service_discovery=false"
	myconf_gn+=" enable_swiftshader=false"
	myconf_gn+=" enable_widevine=$(usex widevine true false)"
	myconf_gn+=" exclude_unwind_tables=true"
	myconf_gn+=" fatal_linker_warnings=false"
	myconf_gn+=" ffmpeg_branding=\"${ffmpeg_branding}\""
	myconf_gn+=" fieldtrial_testing_like_official_build=true"
	myconf_gn+=" google_api_key=\"\""
	myconf_gn+=" google_default_client_id=\"\""
	myconf_gn+=" google_default_client_secret=\"\""
	myconf_gn+=" is_clang=true"
	myconf_gn+=" is_debug=false"
	myconf_gn+=" is_official_build=true"
	myconf_gn+=" optimize_webui=false"
	myconf_gn+=" proprietary_codecs=$(usex proprietary-codecs true false)"
	myconf_gn+=" safe_browsing_mode=0"
	myconf_gn+=" symbol_level=0"
	myconf_gn+=" treat_warnings_as_errors=false"
	myconf_gn+=" use_gnome_keyring=$(usex gnome-keyring true false)"
	myconf_gn+=" use_jumbo_build=$(usex jumbo-build true false)"
	myconf_gn+=" use_official_google_api_keys=false"
	myconf_gn+=" use_sysroot=false"
	myconf_gn+=" use_unofficial_version_number=false"
	# Keep in sync with config_bundles/linux_rooted/gn_flags.map
	myconf_gn+=" custom_toolchain=\"//build/toolchain/linux/unbundle:default\""
	myconf_gn+=" gold_path=\"\""
	myconf_gn+=" goma_dir=\"\""
	if tc-is-cross-compiler; then
		tc-export BUILD_{AR,CC,CXX,NM}
		myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:host\""
		myconf_gn+=" v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\""
	else
		myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:default\""
	fi
	myconf_gn+=" link_pulseaudio=$(usex pulseaudio true false)"
	myconf_gn+=" linux_use_bundled_binutils=false"
	myconf_gn+=" optimize_for_size=false"
	myconf_gn+=" use_allocator=$(usex tcmalloc \"tcmalloc\" \"none\")"
	myconf_gn+=" use_cups=$(usex cups true false)"
	myconf_gn+=" use_custom_libcxx=false"
	myconf_gn+=" use_gio=false"
	myconf_gn+=" use_gold=true"
	myconf_gn+=" use_gtk3=$(usex gtk true false)"
	myconf_gn+=" use_kerberos=$(usex kerberos true false)"
	myconf_gn+=" use_lld=true"
	myconf_gn+=" use_openh264=$(usex openh264 true false)"
	myconf_gn+=" use_pulseaudio=$(usex pulseaudio true false)"
	myconf_gn+=" use_system_freetype=true"
	myconf_gn+=" use_system_harfbuzz=true"
	myconf_gn+=" use_system_lcms2=true"
	myconf_gn+=" use_system_libjpeg=true"
	myconf_gn+=" use_system_zlib=true"
	myconf_gn+=" use_vaapi=$(usex vaapi true false)"

	# wayland
	if use wayland; then
		myconf_gn+=" use_ozone=true"
		myconf_gn+=" ozone_auto_platforms=false"
		myconf_gn+=" ozone_platform_x11=false ozone_platform_wayland=true"
		myconf_gn+=" enable_package_mash_services=true"
		myconf_gn+=" enable_xdg_shell=true xkbcommon=true"
		myconf_gn+=" enable_mus=true"
	fi

	# SC2155
	local myarch
	myarch="$(tc-arch)"
	if [[ $myarch = amd64 ]]; then
		myconf_gn+=" target_cpu=\"x64\""
		ffmpeg_target_arch=x64
	elif [[ $myarch = x86 ]]; then
		myconf_gn+=" target_cpu=\"x86\""
		ffmpeg_target_arch=ia32
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	# Avoid CFLAGS problems (Bug #352457, #390147)
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		# Prevent linker from running out of address space (Bug #471810)
		if use x86; then
			filter-flags "-g*"
		fi

		# Prevent libvpx build failures (Bug #530248, #544702, #546984)
		if [[ ${myarch} == amd64 || ${myarch} == x86 ]]; then
			filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2
		fi
	fi

	# Bug #491582
	export TMPDIR="${WORKDIR}/temp"
	# shellcheck disable=SC2174
	mkdir -p -m 755 "${TMPDIR}" || die

	# But #654216
	addpredict /dev/dri/ #nowarn

	einfo "Configuring Chromium..."
	set -- gn gen --args="${myconf_gn} ${EXTRA_GN}" out/Release
	echo "$@"
	"$@" || die
}

src_compile() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python2*'

	# Build mksnapshot and pax-mark it
	#local x
	#for x in mksnapshot v8_context_snapshot_generator; do
	#	if tc-is-cross-compiler; then
	#		eninja -C out/Release "host/${x}"
	#		pax-mark m "out/Release/host/${x}"
	#	else
	#		eninja -C out/Release "${x}"
	#		pax-mark m "out/Release/${x}"
	#	fi
	#done

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason
	eninja -C out/Release chrome chromedriver
	use suid && eninja -C out/Release chrome_sandbox

	pax-mark m out/Release/chrome
}

src_install() {
	# SC2155
	local CHROMIUM_HOME
	CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome

	if use suid; then
		newexe out/Release/chrome_sandbox chrome-sandbox
		fperms 4755 "${CHROMIUM_HOME}/chrome-sandbox"
	fi

	doexe out/Release/chromedriver

	newexe "${FILESDIR}/${PN}-launcher-r3.sh" chromium-launcher.sh
	sed -i "s:/usr/lib/:/usr/$(get_libdir)/:g" \
		"${ED%/}${CHROMIUM_HOME}/chromium-launcher.sh" || die

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it (Bug #355517)
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	dosym "${CHROMIUM_HOME}/chromedriver" /usr/bin/chromedriver

	# Allow users to override command-line options (Bug #357629)
	insinto /etc/chromium
	newins "${FILESDIR}/chromium.default" "default"

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	insinto "${CHROMIUM_HOME}"
	doins out/Release/*.bin
	doins out/Release/*.pak
	doins out/Release/*.so

	if ! use system-icu; then
		doins out/Release/icudtl.dat
	fi

	doins -r out/Release/locales
	doins -r out/Release/resources

	# Install icons and desktop entry

	local branding size
	for size in 16 22 24 32 48 64 128 256; do
		case ${size} in
			16|32) branding="chrome/app/theme/default_100_percent/chromium" ;;
				*) branding="chrome/app/theme/chromium" ;;
		esac
		newicon -s ${size} "${branding}/product_logo_${size}.png" \
			chromium-browser.png
	done

	local mime_types="text/html;text/xml;application/xhtml+xml;"
	mime_types+="x-scheme-handler/http;x-scheme-handler/https;" # Bug #360797
	mime_types+="x-scheme-handler/ftp;" # Bug #412185
	mime_types+="x-scheme-handler/mailto;x-scheme-handler/webcal;" # Bug #416393
	# shellcheck disable=SC1117
	make_desktop_entry \
		chromium-browser \
		"Chromium" \
		chromium-browser \
		"Network;WebBrowser" \
		"MimeType=${mime_types}\nStartupWMClass=chromium-browser"
	sed -e "/^Exec/s/$/ %U/" -i "${ED%/}"/usr/share/applications/*.desktop || die

	# Install GNOME default application entry (Bug #303100)
	if use gnome; then
		insinto /usr/share/gnome-control-center/default-apps
		doins "${FILESDIR}"/chromium-browser.xml
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
	fi
	readme.gentoo_print_elog
}
