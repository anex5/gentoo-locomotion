# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_{5,6,7}} )

CHROMIUM_LANGS="
	am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he hi hr hu id
	it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw ta te
	th tr uk vi zh-CN zh-TW
"

inherit check-reqs chromium-2 desktop flag-o-matic ninja-utils pax-utils python-r1 readme.gentoo-r1 toolchain-funcs xdg-utils

UGC_PV="${PV/_p/-}"
UGC_P="${PN}-${UGC_PV}"
UGC_WD="${WORKDIR}/${UGC_P}"

DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://github.com/Eloston/ungoogled-chromium https://www.chromium.org/ https://github.com/Igalia/chromium"
SRC_URI="
	https://commondatastorage.googleapis.com/chromium-browser-official/chromium-${PV/_*}.tar.xz
	https://github.com/Eloston/${PN}/archive/${UGC_PV}.tar.gz -> ${UGC_P}.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
VIDEO_CARDS="
	amdgpu exynos intel marvell mediatek msm radeon radeonsi rockchip tegra vc4 virgl
"

IUSE="
	atk cfi component-build closure-compile cups custom-cflags +dbus gnome gold jumbo-build kerberos libcxx
	lld new-tcmalloc optimize-thinlto optimize-webui +pdf +proprietary-codecs
	pulseaudio selinux +suid system-ffmpeg system-harfbuzz +system-icu
	-system-jsoncpp +system-libevent +system-libvpx system-openh264
	+system-openjpeg +system-libdrm -system-wayland +tcmalloc +thinlto widevine
	wayland X libvpx gtk xkbcommon v4l2 v4lplugin +clang swiftshader udev debug
"

for card in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${card}"
done

REQUIRED_USE="
	^^ ( gold lld )
	|| ( $(python_gen_useflags 'python3*') )
	|| ( $(python_gen_useflags 'python2*') )
	cfi? ( thinlto )
	libcxx? ( clang new-tcmalloc )
	new-tcmalloc? ( tcmalloc )
	optimize-thinlto? ( thinlto )
	system-openjpeg? ( pdf )
	x86? ( !lld !thinlto !widevine )
	thinlto? ( clang || ( gold lld ) )
	gtk? ( X )
	gnome? ( gtk dbus )
	atk? ( gnome )
	system-wayland? ( wayland )
"
RESTRICT="
	!system-ffmpeg? ( proprietary-codecs? ( bindist ) )
	!system-openh264? ( bindist )
"

CDEPEND="
	app-arch/snappy:=
	dev-libs/expat:=
	dev-libs/glib:2
	>=dev-libs/libxml2-2.9.4-r3:=[icu]
	dev-libs/libxslt:=
	dev-libs/nspr:=
	>=dev-libs/nss-3.26:=
	>=dev-libs/re2-0.2018.10.01:=
	>=media-libs/alsa-lib-1.0.19:=
	media-libs/flac:=
	media-libs/fontconfig:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	>=media-libs/libwebp-0.4.0:=
	sys-apps/pciutils:=
	sys-libs/zlib:=[minizip]
	virtual/udev
	X? ( 
		x11-libs/cairo:=
		x11-libs/gdk-pixbuf:2
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
	atk? (
		>=app-accessibility/at-spi2-atk-2.26:2
		>=dev-libs/atk-2.26
	)
	closure-compile? ( virtual/jre:* )
	cups? ( >=net-print/cups-1.3.11:= )
	dbus? ( sys-apps/dbus:= )
	kerberos? ( virtual/krb5 )
	pdf? ( media-libs/lcms:= )
	pulseaudio? ( media-sound/pulseaudio:= )
	system-ffmpeg? (
		>=media-video/ffmpeg-3.4.5:=
		|| (
			media-video/ffmpeg[-samba]
			>=net-fs/samba-4.5.16[-debug(-)]
		)
		media-libs/opus:=
	)
	system-harfbuzz? (
		media-libs/freetype:=
		>=media-libs/harfbuzz-2.2.0:0=[icu(-)]
	)
	system-icu? ( >=dev-libs/icu-64:= )
	system-jsoncpp? ( dev-libs/jsoncpp )
	system-libevent? ( dev-libs/libevent )
	system-libvpx? ( >=media-libs/libvpx-1.7.0:=[postproc,svc] )
	system-openh264? ( >=media-libs/openh264-1.6.0:= )
	system-openjpeg? ( media-libs/openjpeg:2= )
	system-wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
	)
	xkbcommon? (
		x11-libs/libxkbcommon
		x11-misc/xkeyboard-config
	)
	libcxx? (
		sys-libs/libcxxabi
		sys-libs/libcxx
	)
	v4lplugin? ( media-tv/v4l-utils )
	gtk? ( x11-libs/gtk+:3[X] )
"
RDEPEND="${CDEPEND}
	virtual/opengl
	virtual/ttf-fonts
	x11-misc/xdg-utils
	selinux? ( sec-policy/selinux-chromium )
	widevine? ( !x86? ( www-plugins/chrome-binary-plugins[widevine(-)] ) )
	!www-client/chromium
	!www-client/ungoogled-chromium-bin
"
# dev-vcs/git (Bug #593476)
# sys-apps/sandbox - https://crbug.com/586444
DEPEND="${CDEPEND}"
BDEPEND="
	app-arch/bzip2:=
	>=app-arch/gzip-1.7
	dev-lang/perl
	!arm? (
		dev-lang/yasm
	)
	<dev-util/gn-0.1583
	>=dev-util/gperf-3.0.3
	>=dev-util/ninja-1.7.2
	dev-vcs/git
	sys-apps/hwids[usb(+)]
	>=sys-devel/bison-2.4.3
	clang? (
		>=sys-devel/clang-7.0.0
		lld? ( >=sys-devel/lld-7.0.0 )
		>=sys-devel/llvm-7.0.0[gold?]
	)
	sys-devel/flex
	virtual/libusb:1
	virtual/pkgconfig
	cfi? ( >=sys-devel/clang-runtime-7.0.0[sanitize] )
	libcxx? (
		sys-libs/libcxx
		sys-libs/libcxxabi
	)
	lld? ( >=sys-devel/lld-7.0.0 )
	optimize-webui? ( >=net-libs/nodejs-7.6.0[inspector] )
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
- media-fonts/noto-emoji
- media-fonts/ja-ipafonts
- media-fonts/takao-fonts
- media-fonts/wqy-microhei
- media-fonts/wqy-zenhei

To fix broken icons on the Downloads page, you should install an icon
theme that covers the appropriate MIME types, and configure this as your
GTK+ icon theme.
"

PATCHES=(
	"${FILESDIR}/chromium-gen-Stop-passing-static-libstdc-to-the-compiler.patch"
	"${FILESDIR}/chromium-compiler-r9.patch"
	"${FILESDIR}/chromium-fix-char_traits.patch"
	"${FILESDIR}/chromium-75-fix-gn-gen.patch"
	"${FILESDIR}/chromium-75-gcc-angle-fix.patch"
	"${FILESDIR}/chromium-75-unique_ptr.patch"
	"${FILESDIR}/chromium-75-lss.patch"
	"${FILESDIR}/chromium-75-noexcept.patch"
	"${FILESDIR}/chromium-75-llvm8.patch"
	"${FILESDIR}/chromium-75-pure-virtual.patch"

	"${FILESDIR}/${PN}-disable-third-party-lzma-sdk-r0.patch"
	"${FILESDIR}/${PN}-empty-array-r0.patch"
	"${FILESDIR}/${PN}-fix-atomic-r0.patch"
	"${FILESDIR}/chromium-test-r0.patch"
 	"${FILESDIR}/chromium-optional-atk-r0.patch"
	"${FILESDIR}/chromium-optional-dbus-r7.patch"
	
	# Extra patches taken from openSUSE
	"${FILESDIR}/${PN}-libusb-interrupt-event-handler-r0.patch"
	"${FILESDIR}/${PN}-system-libusb-r0.patch"
	#"${FILESDIR}/${PN}-system-nspr-r0.patch"
	"${FILESDIR}/${PN}-system-fix-shim-headers-r0.patch"
	"${FILESDIR}/${PN}-ungoogled-chromium-fix-nosafebrowsing-build-r0.patch"
)

S="${WORKDIR}/chromium-${PV/_*}"

pre_build_checks() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		local -x CPP="$(tc-getCXX) -E"
		if tc-is-gcc && ! ver_test "$(gcc-version)" -ge 8.0; then
			die "At least gcc 8.0 is required"
		fi
	fi

	# Check build requirements, bug #541816 and bug #471810 .
	CHECKREQS_MEMORY="3G"
	CHECKREQS_DISK_BUILD="5G"
	if ( shopt -s extglob; is-flagq '-g?(gdb)?([1-9])' ); then
		CHECKREQS_DISK_BUILD="25G"
		if ! use component-build; then
			CHECKREQS_MEMORY="16G"
		fi
	fi
	check-reqs_pkg_setup
}

pkg_pretend() {
	if use custom-cflags && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "USE=custom-cflags bypass strip-flags; you are on your own."
		ewarn "Expect build failures. Don't file bugs using that unsupported USE flag!"
		ewarn
	fi
	pre_build_checks
}

pkg_setup() {
	pre_build_checks
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python3*'

	default

	if use "system-jsoncpp" ; then
		eapply "${FILESDIR}/${PN}-system-jsoncpp-r0.patch" || die
	fi

	if use "system-openjpeg" ; then
		eapply "${FILESDIR}/${PN}-system-openjpeg-r0.patch" || die
	fi

	if use optimize-webui; then
		mkdir -p third_party/node/linux/node-linux-x64/bin || die
		ln -s "${EPREFIX}/usr/bin/node" \
			third_party/node/linux/node-linux-x64/bin/node || die
	fi
	
	# Apply extra patches (taken from Igalia)
	local p="${FILESDIR}/igalia-$(ver_cut 1-1)"

	eapply "${p}/0001-ozone-wayland-Factored-the-clipboard-logic-out-of-Wa.patch" || die
	eapply "${p}/0002-Convert-wayland-buffer-to-the-new-shared-memory-API.patch" || die
	eapply "${p}/0003-Migrate-WaylandCanvasSurface-to-the-new-shared-memor.patch" || die
	eapply "${p}/0004-ozone-wayland-Ease-the-buffer-swap-and-maintenance.patch" || die
	eapply "${p}/0005-ozone-wayland-Fix-presentation-feedback-flags.patch" || die
	eapply "${p}/0006-wayland-Do-not-release-shared-memory-fd-when-passing.patch" || die
	eapply "${p}/0007-ozone-wayland-Don-t-wait-for-frame-callback-after-su.patch" || die
	eapply "${p}/0008-ozone-wayland-Do-not-add-window-if-manager-does-not-.patch" || die
	eapply "${p}/0009-ozone-wayland-Fix-NativeGpuMemoryBuffers-usage.patch" || die
	eapply "${p}/0010-ozone-wayland-Add-immediate-release-support.patch" || die
	eapply "${p}/0011-ozone-wayland-Wrap-wl_shm-to-WaylandShm.patch" || die
	eapply "${p}/0012-ozone-wayland-Shm-Proxy-make-mojo-calls-on-the-gpu-t.patch" || die
	eapply "${p}/0013-ozone-wayland-Shm-add-buffer_id.patch" || die
	eapply "${p}/0014-ozone-wayland-Unite-Wayland-ShmBufferManager-and-Buf.patch" || die
	eapply "${p}/0015-ozone-wayland-Stop-providing-WaylandConnection-throu.patch" || die
	eapply "${p}/0016-ozone-wayland-Improve-logging-when-creating-gbm-buff.patch" || die
	eapply "${p}/0017-ozone-wayland-Establish-BufferManagerGpu-and-BufferM.patch" || die
	eapply "${p}/0018-ozone-wayland-Use-new-shmen-API-when-loading-keymap.patch" || die
	eapply "${p}/0019-ozone-wayland-Prepare-WaylandCanvasSurface-for-compl.patch" || die
	eapply "${p}/0020-ozone-wayland-Reset-surface-contents-in-a-safe-way.patch" || die
	eapply "${p}/0021-Ozone-Wayland-Manager-make-mojo-calls-on-IO-thread.patch" || die
	eapply "${p}/0022-ozone-wayland-Manager-tests-exercise-tests-with-mojo.patch" || die
	eapply "${p}/0023-ozone-wayland-Fix-broken-software-rendering-path.patch" || die
	eapply "${p}/0001-v4l2_device-CanCreateEGLImageFrom-support-all-ARM-So.patch" || die
	eapply "${p}/0001-Add-support-for-V4L2VDA-on-Linux.patch" || die
	eapply "${p}/0002-Add-mmap-via-libv4l-to-generic_v4l2_device.patch" || die
	eapply "${p}/0001-ozone-wayland-Fix-method-prototype-match.patch" || die

	# Hack for libusb stuff (taken from openSUSE)
	rm third_party/libusb/src/libusb/libusb.h || die
	cp -a "${EPREFIX}/usr/include/libusb-1.0/libusb.h" \
		third_party/libusb/src/libusb/libusb.h || die

	use gold && eapply "${FILESDIR}/${PN}-gold-r3.patch"

	use widevine && eapply "${FILESDIR}/chromium-widevine-r4.patch"

	use system-libdrm && eapply "${FILESDIR}/chromium-system-libdrm.patch"

	ebegin "Pruning binaries"
	"${UGC_WD}/utils/prune_binaries.py" . "${UGC_WD}/pruning.list"
	eend $? || die

	ebegin "Applying ungoogled-chromium patches"
	"${UGC_WD}/utils/patches.py" apply . "${UGC_WD}/patches"
	eend $? || die

	ebegin "Applying domain substitution"
	"${UGC_WD}/utils/domain_substitution.py" apply -r "${UGC_WD}/domain_regex.list" -f "${UGC_WD}/domain_substitution.list" -c build/domsubcache.tar.gz .
	eend $? || die

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
		chrome/third_party/mozilla_security_manager
		courgette/third_party
		net/third_party/mozilla_security_manager
		net/third_party/nss
		net/third_party/quic
		net/third_party/uri_template
		third_party/abseil-cpp
		third_party/adobe
		third_party/angle
		third_party/angle/src/common/third_party/base
		third_party/angle/src/common/third_party/smhasher
		third_party/angle/src/common/third_party/xxhash
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
		third_party/axe-core
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
		third_party/dav1d
		third_party/dawn
		third_party/devscripts
		third_party/dom_distiller_js
		third_party/emoji-segmenter
		third_party/flatbuffers
		third_party/flot
		third_party/glslang
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
		third_party/libaom/source/libaom/third_party/vector
		third_party/libaom/source/libaom/third_party/x86inc
		third_party/libjingle
		third_party/libphonenumber
		third_party/libsecret
		third_party/libsrtp
		third_party/libsync
		third_party/libudev
		third_party/libusb
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
		third_party/nasm
		third_party/openmax_dl
		third_party/ots
		third_party/perfetto
		third_party/pffft
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
		third_party/skia/include/third_party/vulkan
		third_party/skia/third_party/gif
		third_party/skia/third_party/skcms
		third_party/skia/third_party/vulkan
		third_party/smhasher
		third_party/speech-dispatcher
		third_party/spirv-headers
		third_party/SPIRV-Tools
		third_party/sqlite
		third_party/ungoogled
		third_party/usb_ids
		third_party/usrsctp
		third_party/vulkan
		third_party/web-animations-js
		third_party/webdriver
		third_party/webrtc
		third_party/webrtc/common_audio/third_party/fft4g
		third_party/webrtc/common_audio/third_party/spl_sqrt_floor
		third_party/webrtc/modules/third_party/fft
		third_party/webrtc/modules/third_party/g711
		third_party/webrtc/modules/third_party/g722
		third_party/webrtc/rtc_base/third_party/base64
		third_party/webrtc/rtc_base/third_party/sigslot
		third_party/widevine
		third_party/woff2
		third_party/xdg-utils
		third_party/yasm/run_yasm.py
		third_party/zlib/google
		url/third_party/mozilla
		v8/src/third_party/siphash
		v8/src/third_party/valgrind
		v8/src/third_party/utf8-decoder
		v8/third_party/inspector_protocol
		v8/third_party/v8
	)

	use closure-compile && keeplibs+=( third_party/closure_compiler )
	use optimize-webui && keeplibs+=(
		third_party/node
		third_party/node/node_modules/polymer-bundler/lib/third_party/UglifyJS2
	)
	use pdf && keeplibs+=(
		third_party/pdfium
		third_party/pdfium/third_party/agg23
		third_party/pdfium/third_party/base
		third_party/pdfium/third_party/bigint
		third_party/pdfium/third_party/freetype
		third_party/pdfium/third_party/lcms
		third_party/pdfium/third_party/libpng16
		third_party/pdfium/third_party/libtiff
		third_party/pdfium/third_party/skia_shared
	)
	# To do system-openjpeg req files
	#use system-openjpeg || 
	keeplibs+=(
		third_party/pdfium/third_party/libopenjpeg20
	)
	use swiftshader && keeplibs+=(
		third_party/swiftshader
		third_party/swiftshader/third_party/llvm-subzero
		third_party/swiftshader/third_party/subzero

	)
	use v4l2 && keeplibs+=(
		third_party/v4l-utils
	)
	use system-ffmpeg || keeplibs+=( third_party/ffmpeg third_party/opus )
	use system-harfbuzz || keeplibs+=(
		third_party/freetype
		third_party/harfbuzz-ng
	)
	use system-icu || keeplibs+=( third_party/icu )
	use system-jsoncpp || keeplibs+=( third_party/jsoncpp )
	use libcxx || keeplibs+=( buildtools/third_party/libc++ buildtools/third_party/libc++abi )
	use system-libdrm || keeplibs+=( third_party/libdrm third_party/libdrm/src/include/drm )
	use system-libevent || keeplibs+=( base/third_party/libevent )
	use system-libvpx || keeplibs+=(
		third_party/libvpx
		third_party/libvpx/source/libvpx/third_party/x86inc
	)
	use system-wayland || keeplibs+=( third_party/wayland third_party/wayland-protocols )
	keeplibs+=( third_party/minigbm )
	use system-openh264 || keeplibs+=( third_party/openh264 )
	use tcmalloc && keeplibs+=( third_party/tcmalloc )

	# Remove most bundled libraries, some are still needed
	python_setup 'python2*'
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove || die
}

# Handle all CFLAGS/CXXFLAGS/etc... munging here.
setup_compile_flags() {
	# Avoid CFLAGS problems (Bug #352457, #390147)
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		# Filter common/redundant flags. See build/config/compiler/BUILD.gn
		filter-flags -fomit-frame-pointer -fno-omit-frame-pointer \
			-fstack-protector* -fno-stack-protector* -fuse-ld=* -g* -Wl,*

		# Prevent libvpx build failures (Bug #530248, #544702, #546984)
		filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2
	fi

	# -clang-syntax is a flag that enable us to do clang syntax checking on
	# top of building Chrome with gcc. Since Chrome itself is clang clean,
	# there is no need to check it again. And this flag has
	# nothing to do with USE=clang.
	use clang && filter-flags -clang-syntax 

	# Turns out this is only really supported by Clang. See crosbug.com/615466
	# Add "-faddrsig" flag required to efficiently support "--icf=all".
	if use clang; then
		append-flags -faddrsig
		append-flags -Wno-unknown-warning-option
		export CXXFLAGS_host+=" -Wno-unknown-warning-option"
		export CFLAGS_host+=" -Wno-unknown-warning-option"
		if use libcxx; then
			append-cxxflags "-stdlib=libc++"
			append-ldflags "-stdlib=libc++ -Wl,-lc++abi"
		else
			if has_version 'sys-devel/clang[default-libcxx]'; then
				append-cxxflags "-stdlib=libstdc++"
				append-ldflags "-stdlib=libstdc++"
			fi
		fi
	fi
	append-flags -ffunction-sections

	# 'gcc_s' is still required if 'compiler-rt' is Clang's default rtlib
	has_version 'sys-devel/clang[default-compiler-rt]' && \
		append-ldflags "-Wl,-lgcc_s"

	if use thinlto; then
		# We need to change the default value of import-instr-limit in
		# LLVM to limit the text size increase. The default value is
		# 100, and we change it to 30 to reduce the text size increase
		# from 25% to 10%. The performance number of page_cycler is the
		# same on two of the thinLTO configurations, we got 1% slowdown
		# on speedometer when changing import-instr-limit from 100 to 30.
		local thinlto_ldflag=( "-Wl,-plugin-opt,-import-instr-limit=30" )

		use gold && thinlto_ldflag+=(
			"-Wl,-plugin-opt=thinlto"
			"-Wl,-plugin-opt,jobs=$(makeopts_jobs)"
		)

		use lld && thinlto_ldflag+=( "-Wl,--thinlto-jobs=$(makeopts_jobs)" )

		append-ldflags "${thinlto_ldflag[*]}"
	else
		use gold && append-ldflags "-Wl,--threads -Wl,--thread-count=$(makeopts_jobs)"
	fi

	# Don't complain if Chromium uses a diagnostic option that is not yet
	# implemented in the compiler version used by the user. This is only
	# supported by Clang.
	append-flags -Wno-unknown-warning-option

	# Facilitate deterministic builds (taken from build/config/compiler/BUILD.gn)
	append-cflags -Wno-builtin-macro-redefined
	append-cxxflags -Wno-builtin-macro-redefined
	append-cppflags "-D__DATE__= -D__TIME__= -D__TIMESTAMP__="

	# Enable std::vector []-operator bounds checking.
	append-cxxflags -D__google_stl_debug_vector=1

	# Workaround: Disable fatal linker warnings on arm64/lld.
	# https://crbug.com/913071
	use arm64 && append-ldflags "-Wl,--no-fatal-warnings"

	local flags
	einfo "Building with the compiler settings:"
	for flags in {C,CXX,CPP,LD}FLAGS; do
		einfo "  ${flags} = ${!flags}"
	done
}

src_configure() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python2*'

	tc-export CXX CC AR AS NM RANLIB STRIP
	export CC_host=$(usex clang "${CBUILD}-clang" "$(tc-getBUILD_CC)")
	export CXX_host=$(usex clang "${CBUILD}-clang++" "$(tc-getBUILD_CXX)")
	export CC=$(usex clang "${CBUILD}-clang" "$(tc-getBUILD_CC)")
	export CXX=$(usex clang "${CBUILD}-clang++" "$(tc-getBUILD_CXX)")
	export NM_host=$(tc-getBUILD_NM)
	export READELF="${CBUILD}-readelf"
	export READELF_host="${CBUILD}-readelf"
	# Temporarily use llvm-objcopy to generate split-debug file with non-debug
	# sections preserved, b/127337806. This workaround only works because
	# llvm-objcopy currently does not support "--only-keep-debug" flag.
	export OBJCOPY=llvm-objcopy
	# Use g++ as the linker driver.
	export LD="${CXX}"
	export LD_host=${CXX_host}
	# We need below change when USE="thinlto" is set. We set this globally
	# so that users can turn on the "use_thin_lto" in the simplechrome
	# flow more easily. We might be able to remove the dependency on use
	# clang because clang is the default compiler now.
	if use clang ; then
		# use nm from llvm, https://crbug.com/917193
		export NM="llvm-nm"
		export NM_host="llvm-nm"
		export AR="llvm-ar"
		# USE=thinlto affects host build, we need to set host AR to
		# llvm-ar to make sure host package builds with thinlto.
		# crbug.com/731335
		export AR_host="llvm-ar"
		export RANLIB="llvm-ranlib"
	fi

	# Use system-provided libraries.
	# TODO: freetype -- remove sources (https://bugs.chromium.org/p/pdfium/issues/detail?id=733).
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_libsrtp (bug #459932).
	# TODO: use_system_protobuf (bug #525560).
	# TODO: use_system_ssl (http://crbug.com/58087).
	# TODO: use_system_sqlite (http://crbug.com/22208).

	# libevent: https://bugs.gentoo.org/593458

	local gn_system_libraries=(
		flac
		fontconfig
		libpng
		libusb
		libwebp
		libxml
		libxslt
		re2
		snappy
		yasm
		zlib
	)

	use system-ffmpeg && gn_system_libraries+=( ffmpeg opus )
	use system-harfbuzz && gn_system_libraries+=( freetype )
	use system-icu && gn_system_libraries+=( icu )
	use system-libdrm && gn_system_libraries+=( libdrm )
	use system-libevent && gn_system_libraries+=( libevent )
	use system-libvpx && gn_system_libraries+=( libvpx )
	#use system-wayland && gn_system_libraries+=( libwayland )
	use system-openh264 && gn_system_libraries+=( openh264 )
	use system-openjpeg && gn_system_libraries+=( libjpeg )

	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" || die

	local myconf_gn=(
		# Clang features
		"use_clang_coverage=false"
		"is_cfi=$(usetf cfi)" # Implies use_cfi_icall=true 
		"is_clang=$(usetf clang)"
		"clang_use_chrome_plugins=false"
		"thin_lto_enable_optimizations=$(usetf optimize-thinlto)"
		"use_lld=$(usetf lld)"
		"use_thin_lto=$(usetf thinlto)"
		"rtc_use_lto=$(usetf thinlto)"
		"clang_use_default_sample_profile=false"

		#"use_system_libcxx=$(usetf libcxx)"

		# UGC's "common" GN flags (config_bundles/common/gn_flags.map
		"enable_hangout_services_extension=false"

		"enable_mdns=false"

		# Disable nacl, we can't build without pnacl (http://crbug.com/269560).
		"enable_nacl=false"
		"enable_nacl_nonsfi=false"
		"enable_native_notifications=false"
		
		"enable_one_click_signin=false"
		"enable_reading_list=false"
		"enable_remoting=false"
		"enable_reporting=false"
		"enable_service_discovery=false"

		"exclude_unwind_tables=true"
		"fatal_linker_warnings=false"

		"fieldtrial_testing_like_official_build=true"
		"google_api_key=\"\""
		"google_default_client_id=\"\""
		"google_default_client_secret=\"\""

		"is_official_build=true"
		"optimize_webui=$(usetf optimize-webui)"
		"proprietary_codecs=$(usetf proprietary-codecs)"
		"safe_browsing_mode=0"

		"treat_warnings_as_errors=false"
		"use_gnome_keyring=false" # Deprecated by libsecret
		"use_jumbo_build=$(usetf jumbo-build)"
		"jumbo_file_merge_limit=50"
		"use_official_google_api_keys=false"

		"use_sysroot=false"
		"use_unofficial_version_number=false"

		# UGC's "linux_rooted" GN flags (config_bundles/linux_rooted/gn_flags.map)
		"custom_toolchain=\"//build/toolchain/linux/unbundle:default\""

		"gold_path=\"\""
		"goma_dir=\"\""
		"link_pulseaudio=$(usetf pulseaudio)"
		"linux_use_bundled_binutils=false"

		"use_cups=$(usetf cups)"
		"use_custom_libcxx=false"

		"use_kerberos=$(usetf kerberos)"

		"use_pulseaudio=$(usetf pulseaudio)"
		# HarfBuzz and FreeType need to be built together in a specific way
		# to get FreeType autohinting to work properly. Chromium bundles
		# FreeType and HarfBuzz to meet that need. (https://crbug.com/694137)
		"use_system_freetype=$(usetf system-harfbuzz)"
		"use_system_harfbuzz=$(usetf system-harfbuzz)"
		"use_system_lcms2=$(usetf pdf)"
		#"use_system_libopenjpeg2=$(usetf system-openjpeg)"

		"use_system_zlib=true"
		#"rtc_build_json=$(usex system-jsoncpp false true)"

		# Debug flags
		"is_debug=$(usetf debug)"
		"use_debug_fission=false"
		"symbol_level=$(usex debug 2 0)"
		"strip_debug_info=$(usex debug false true)"
		#"sanitizer_no_symbols=$(usex debug false true)"
		"blink_symbol_level=$(usex debug 2 0)"
		"enable_iterator_debugging=$(usetf debug)"
		#"remove_webcore_debug_symbols=$(usex debug false true)"

		# Codecs
		"proprietary_codecs=$(usetf proprietary-codecs)"
		"ffmpeg_branding=\"$(usex proprietary-codecs Chrome Chromium)\""
		"enable_hls_sample_aes=true"
		"use_openh264=true" #Encoding
		"rtc_use_h264=true" #Decoding
		"enable_ac3_eac3_audio_demuxing=true"
		"enable_hevc_demuxing=true"
		"enable_dolby_vision_demuxing=true"
		"enable_av1_decoder=true"
		"enable_mse_mpeg2ts_stream_parser=true"
		"media_use_ffmpeg=true"
		"enable_ffmpeg_video_decoders=true"
		"use_v4l2_codec=$(usetf v4l2)"
		"use_linux_v4l2_only=$(usetf v4l2)"
		"use_v4lplugin=$(usetf v4lplugin)"
		"rtc_build_libvpx=$(usetf libvpx)"
		"media_use_libvpx=$(usetf libvpx)"
		"rtc_libvpx_build_vp9=false"
		#"enable_runtime_media_renderer_selection=true"
		"enable_mpeg_h_audio_demuxing=true"
		"enable_vulkan=false" 
		"use_vaapi=false"
		"enable_plugins=true"
		"use_cras=false"

		# Additional flags
		"is_component_build=$(usetf component-build)"
		"enable_desktop_in_product_help=false"
		"enable_offline_pages=false" #Android
		"closure_compile=$(usetf closure-compile)"
		"enable_swiftshader=$(usetf swiftshader)"
		"enable_widevine=$(usetf widevine)"
		"enable_pdf=$(usetf pdf)"
		"enable_print_preview=$(usetf pdf)"
		"rtc_build_examples=false"
	    #"use_boringssl_for_http_transport_socket=true"
		"use_atk=$(usetf atk)"
		"use_dbus=$(usetf dbus)"
		"use_icf=true"
		"use_udev=$(usetf udev)"
		"rtc_build_libevent=$(usetf udev)"
		"rtc_enable_libevent=$(usetf udev)"
		"is_desktop_linux=true"

		# Enables the soon-to-be default tcmalloc (https://crbug.com/724399)
		# It is relevant only when use_allocator == "tcmalloc"
		"use_new_tcmalloc=$(usetf new-tcmalloc)"
		"use_allocator=\"$(usex tcmalloc tcmalloc none)\""
		"use_allocator_shim=$(usetf tcmalloc)"

		"rtc_use_gtk=$(usetf gtk)"
		"rtc_use_x11=$(usetf X)"
		"rtc_build_examples=false"
		"use_gio=$(usetf gnome)"
		#"use_gconf=$(usetf gnome)"
		"use_xkbcommon=$(usetf xkbcommon)"
	)
	
	use cfi	&& myconf_gn+=( "use_cfi_cast=$(usetf cfi)" )
	# use_cfi_icall only works with LLD
	use cfi && myconf_gn+=( "use_cfi_icall=$(usetf lld)" )

	if tc-is-cross-compiler; then
		tc-export BUILD_{AR,CC,CXX,NM}
		myconf_gn+=(" host_toolchain=\"//build/toolchain/linux/unbundle:host\"")
		myconf_gn+=(" v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\"")
	else
		myconf_gn+=(" host_toolchain=\"//build/toolchain/linux/unbundle:default\"")
	fi
	#use system-jsoncpp && "rtc_jsoncpp_root=/usr/include/jsoncpp/json"

	# wayland
	if use wayland; then
		myconf_gn+=(
		"use_egl=true"
		"toolkit_views=true" 
		"use_system_libwayland=$(usetf system-wayland)"
		"use_ozone=true"
		"use_aura=true"
		"ozone_auto_platforms=false"
		"ozone_platform_x11=$(usetf X)"
		"ozone_platform_wayland=true"
		"ozone_platform=\"wayland\""
		"ozone_platform_gbm=true"
		"enable_mus=false"
		#"use_system_minigbm=$(usetf system-minigbm)"
		"use_system_minigbm=false"
		"use_system_libdrm=$(usetf system-libdrm)"
		"enable_background_mode=true"
		"use_wayland_gbm=true"
		)
	fi

	setup_compile_flags

	local myarch="$(tc-arch)"

	if [[ $myarch = amd64 ]] ; then
		myconf_gn+=" target_cpu=\"x64\""
		ffmpeg_target_arch=x64
	elif [[ $myarch = x86 ]] ; then
		myconf_gn+=" target_cpu=\"x86\""
		ffmpeg_target_arch=ia32

		# This is normally defined by compiler_cpu_abi in
		# build/config/compiler/BUILD.gn, but we patch that part out.
		append-flags -msse2 -mfpmath=sse -mmmx
	elif [[ $myarch = arm64 ]] ; then
		myconf_gn+=" target_cpu=\"arm64\""
		ffmpeg_target_arch=arm64
	elif [[ $myarch = arm ]] ; then
		myconf_gn+=" target_cpu=\"arm\""
		ffmpeg_target_arch=$(usex neon arm-neon arm)
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	if false; then
	#if ! use system-ffmpeg; then
		local build_ffmpeg_args=""
		if use pic && [[ "${ffmpeg_target_arch}" == "ia32" ]]; then
			build_ffmpeg_args+=" --disable-asm"
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

	# Bug #491582
	export TMPDIR="${WORKDIR}/temp"
	mkdir -p -m 755 "${TMPDIR}" || die

	# Bug #654216
	addpredict /dev/dri/ #nowarn

	einfo "Configuring Chromium..."
	set -- gn gen --args="${myconf_gn[*]} ${EXTRA_GN}" out/Release
	echo "$@"
	"$@" || die
}

src_compile() {
	# Final link uses lots of file descriptors
	ulimit -n 4096

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python2*'

	# shellcheck disable=SC2086
	# Avoid falling back to preprocessor mode when sources contain time macros
	has ccache ${FEATURES} && \
		export CCACHE_SLOPPINESS="${CCACHE_SLOPPINESS:-time_macros}"

	# Build mksnapshot and pax-mark it
	local x
	for x in mksnapshot v8_context_snapshot_generator; do
		eninja -C out/Release "${x}"
		pax-mark m "out/Release/${x}"
	done

	# Work around broken deps
	eninja -C out/Release gen/ui/accessibility/ax_enums.mojom{,-shared}.h

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason
	eninja -C out/Release chrome chromedriver
	use suid && eninja -C out/Release chrome_sandbox

	pax-mark m out/Release/chrome
}

src_install() {
	local CHROMIUM_HOME # SC2155
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
		"${ED}${CHROMIUM_HOME}/chromium-launcher.sh" || die

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it (Bug #355517)
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	dosym "${CHROMIUM_HOME}/chromedriver" /usr/bin/chromedriver

	# Allow users to override command-line options (Bug #357629)
	insinto /etc/chromium
	newins "${FILESDIR}/${PN}.default" "default"

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	insinto "${CHROMIUM_HOME}"
	doins out/Release/*.bin
	doins out/Release/*.pak
	doins out/Release/*.so

	use system-icu || doins out/Release/icudtl.dat

	doins -r out/Release/locales
	doins -r out/Release/resources

	if [[ -d out/Release/swiftshader ]]; then
		insinto "${CHROMIUM_HOME}/swiftshader"
		doins out/Release/swiftshader/*.so
	fi

	# Install icons and desktop entry
	local branding size
	for size in 16 22 24 32 48 64 128 256; do
		case ${size} in
			16|32) branding="chrome/app/theme/default_100_percent/chromium" ;;
				*) branding="chrome/app/theme/chromium" ;;
		esac
		newicon -s ${size} "${branding}/product_logo_${size}.png" chromium-browser.png
	done

	if use gnome; then
		local mime_types="text/html;text/xml;application/xhtml+xml;"
		mime_types+="x-scheme-handler/http;x-scheme-handler/https;" # Bug #360797
		mime_types+="x-scheme-handler/ftp;" # Bug #412185
		mime_types+="x-scheme-handler/mailto;x-scheme-handler/webcal;" # Bug #416393
		make_desktop_entry \
			chromium-browser \
			"Chromium" \
			chromium-browser \
			"Network;WebBrowser" \
			"MimeType=${mime_types}\\nStartupWMClass=chromium-browser"
		sed -i "/^Exec/s/$/ %U/" "${ED}"/usr/share/applications/*.desktop || die
	
		# Install GNOME default application entry (Bug #303100)
		insinto /usr/share/gnome-control-center/default-apps
		doins "${FILESDIR}/chromium-browser.xml"
	fi

	readme.gentoo_create_doc
}

usetf() {
	usex "$1" true false
}

update_caches() {
	if type gtk-update-icon-cache &>/dev/null; then
		ebegin "Updating GTK icon cache"
		gtk-update-icon-cache "${EROOT}/usr/share/icons/hicolor"
		eend $? || die
	fi
	xdg_desktop_database_update
}

pkg_postrm() {
	use gnome && update_caches
}

pkg_postinst() {
	use gnome && update_caches
	readme.gentoo_print_elog
}
