# Copyright 2009-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )

PYTHON_REQ_USE="xml"

CHROMIUM_LANGS="am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW"

inherit check-reqs chromium-2 desktop flag-o-matic multilib ninja-utils pax-utils portability python-any-r1 readme.gentoo-r1 toolchain-funcs xdg-utils

UGC_PVR="${PVR/r}"
UGC_PF="${PN}-${UGC_PVR}"
UGC_URL="https://github.com/Eloston/${PN}/archive/"
#UGC_COMMIT_ID="27c9e9fabd38001b32d148f7b3f99b4d31e67277"

if [ -z "$UGC_COMMIT_ID" ]
then
	UGC_URL="${UGC_URL}${UGC_PVR}.tar.gz -> ${UGC_PF}.tar.gz"
	UGC_WD="${WORKDIR}/${UGC_PF}"
else
	UGC_URL="${UGC_URL}${UGC_COMMIT_ID}.tar.gz -> ${PN}-${UGC_COMMIT_ID}.tar.gz"
	UGC_WD="${WORKDIR}/ungoogled-chromium-${UGC_COMMIT_ID}"
fi

DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://github.com/Eloston/ungoogled-chromium"
PATCHSET="7"
PATCHSET_NAME="chromium-$(ver_cut 1)-patchset-${PATCHSET}"
SRC_URI="https://commondatastorage.googleapis.com/chromium-browser-official/chromium-${PV/_*}.tar.xz
	https://files.pythonhosted.org/packages/ed/7b/bbf89ca71e722b7f9464ebffe4b5ee20a9e5c9a555a56e2d3914bb9119a6/setuptools-44.1.0.zip
	https://github.com/stha09/chromium-patches/releases/download/${PATCHSET_NAME}/${PATCHSET_NAME}.tar.xz
	${UGC_URL}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="atk alsa cfi clang convert-dict cups custom-cflags chromedriver dbus debug gold gtk hangouts headless js-type-check libcxx kerberos man optimize-thinlto optimize-webui +pdf pgo +proprietary-codecs pulseaudio selinux +suid +system-re2 +system-ffmpeg +system-harfbuzz +system-icu +system-jsoncpp +system-libevent +system-libdrm +system-libvpx +system-openh264 +system-openjpeg libvpx +lld swiftshader screencast +tcmalloc thinlto udev v4l2 v4lplugin vaapi vdpau vulkan wayland widevine X xkbcommon xdg"
RESTRICT="
	!system-ffmpeg? ( proprietary-codecs? ( bindist ) )
	!system-openh264? ( bindist )
"
REQUIRED_USE="
	|| ( X wayland headless )
	^^ ( gold lld )
	v4l2? ( wayland )
	v4lplugin? ( v4l2 )
	cfi? ( thinlto libcxx )
	libcxx? ( clang )
	pgo? ( clang )
	optimize-thinlto? ( thinlto )
	system-openjpeg? ( pdf )
	thinlto? ( clang )
	gtk? ( || ( X wayland ) )
	atk? ( gtk )
	screencast? ( wayland )
	system-libdrm? ( wayland )
	system-libvpx? ( libvpx )
	x86? ( !thinlto !widevine )
"

COMMON_DEPEND="
	app-arch/bzip2:=
	app-arch/snappy:=
	dev-libs/expat:=
	dev-libs/glib:2
	>=dev-libs/libxml2-2.9.4-r3:=[icu]
	dev-libs/libxslt:=
	dev-libs/nspr:=
	>=dev-libs/nss-3.26:=
	alsa? ( >=media-libs/alsa-lib-1.0.19:= )
	media-libs/flac:=
	media-libs/fontconfig:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	>=media-libs/libwebp-0.4.0:=
	media-libs/mesa:=[gbm]
	sys-apps/pciutils:=
	sys-libs/zlib:=[minizip]
	virtual/udev
	X? (
		x11-libs/cairo:=[X]
		x11-libs/gdk-pixbuf:2
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
		x11-libs/pango:=[X]
	)
	gtk? (
		x11-libs/gtk+:3[wayland?,X?]
	)
	atk? (
		>=app-accessibility/at-spi2-atk-2.26:2
		>=app-accessibility/at-spi2-core-2.26:2
	)
	js-type-check? ( virtual/jre:* )
	cups? ( >=net-print/cups-1.3.11:= )
	dbus? ( sys-apps/dbus:= )
	kerberos? ( virtual/krb5 )
	pdf? ( media-libs/lcms:= )
	pulseaudio? ( ||
		(
			media-sound/pulseaudio:=
			>=media-sound/apulse-0.1.9
		)
	)
	system-ffmpeg? (
		>=media-video/ffmpeg-4.3:=
		|| (
			media-video/ffmpeg[-samba]
			>=net-fs/samba-4.5.10-r1[-debug(-)]
		)
		>=media-libs/opus-1.3.1:=
	)
	system-harfbuzz? (
		media-libs/freetype:=
		>=media-libs/harfbuzz-2.4.0:0=[icu(-)]
	)
	system-icu? ( >=dev-libs/icu-67:= )
	system-jsoncpp? ( dev-libs/jsoncpp )
	system-libevent? ( dev-libs/libevent )
	system-libvpx? ( >=media-libs/libvpx-1.9.0:=[postproc,svc] )
	system-openh264? ( >=media-libs/openh264-1.6.0:= )
	system-openjpeg? ( media-libs/openjpeg:2= )
	system-re2? ( >=dev-libs/re2-0:= )
	vaapi? ( >=x11-libs/libva-2.10.0:= )

	xkbcommon? (
		x11-libs/libxkbcommon
		x11-misc/xkeyboard-config
	)
	libcxx? (
		sys-libs/libcxx
	)
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
		dev-libs/libffi:=
		system-libdrm? ( x11-libs/libdrm )
	)
	screencast? ( media-video/pipewire:0/0.3 )
	v4lplugin? ( media-tv/v4l-utils )
"
# For nvidia-drivers blocker, see bug #413637 .
RDEPEND="${COMMON_DEPEND}
	x11-misc/xdg-utils
	virtual/opengl
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-chromium )
	tcmalloc? ( !<x11-drivers/nvidia-drivers-331.20 )
	!x86? ( widevine? ( ~www-plugins/chrome-binary-plugins-${PV} ) )
	!www-client/chromium
	!www-client/chromium-bin
	!www-client/ungoogled-chromium-bin
"
DEPEND="${COMMON_DEPEND}
"
# dev-vcs/git - https://bugs.gentoo.org/593476
BDEPEND="
	${PYTHON_DEPS}
	>=app-arch/gzip-1.7
	app-arch/unzip
	dev-lang/perl
	>=dev-util/gn-0.1807
	dev-vcs/git
	>=dev-util/gperf-3.0.3
	>=dev-util/ninja-1.7.2
	>=net-libs/nodejs-7.6.0[inspector]
	sys-apps/hwids[usb(+)]
	>=sys-devel/bison-2.4.3
	sys-devel/flex
	virtual/pkgconfig
	js-type-check? ( virtual/jre )
	!system-libvpx? (
		amd64? ( dev-lang/yasm )
		x86? ( dev-lang/yasm )
	)
	clang? ( sys-devel/clang )
	thinlto? ( sys-devel/lld )
	cfi? ( sys-devel/clang-runtime[sanitize] )
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
- media-fonts/noto-emoji
- media-fonts/ja-ipafonts
- media-fonts/takao-fonts
- media-fonts/wqy-microhei
- media-fonts/wqy-zenhei

To fix broken icons on the Downloads page, you should install an icon
theme that covers the appropriate MIME types, and configure this as your
GTK+ icon theme.

For native file dialogs in KDE, install kde-apps/kdialog.

To make password storage work with your desktop environment you may
have install one of the supported credentials management applications:
- app-crypt/libsecret (GNOME)
- kde-frameworks/kwallet (KDE)
If you have one of above packages installed, but don't want to use
them in Chromium, then add --password-store=basic to CHROMIUM_FLAGS
in /etc/chromium/default.
"

S="${WORKDIR}/chromium-${PV/_*}"

pre_build_checks() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		local -x CPP="$(tc-getCXX) -E"
		if tc-is-gcc && ! ver_test "$(gcc-version)" -ge 9.2; then
			die "At least gcc 9.2 is required"
		fi
		if use clang; then
			if ! ver_test "$(clang-major-version)" -ge 12; then
				die "At least clang 12 is required"
			fi
		fi
	fi

	# Check build requirements, bug #541816 and bug #471810 .
	CHECKREQS_MEMORY="3G"
	CHECKREQS_DISK_BUILD="8G"
	if ( shopt -s extglob; is-flagq '-g?(gdb)?([1-9])' ); then
		CHECKREQS_DISK_BUILD="16G"
	fi
	check-reqs_pkg_setup
}

pkg_pretend() {
	if use custom-cflags && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "USE=custom-cflags bypasses strip-flags"
		ewarn "Consider disabling this USE flag if something breaks"
		ewarn
	fi

	if use libcxx; then
		ewarn
		ewarn "Ensure system-* c++ dependencies are compiled with libcxx library"
        ewarn
	fi

	if use system-libvpx && use vaapi; then
		ewarn
		ewarn "New vaapi code depends heavily on libvpx-1.9, see #43"
		ewarn "Consider disabling system-libvpx USE flag if using vaapi"
		ewarn "A patch to make vaapi compatible with system libvpx-1.9 is welcome"
		ewarn
		die "The build will fail!"
	fi

	pre_build_checks
}

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config

	# nvidia-drivers does not work correctly with Ozone due to unsupported EGLStreams
	if use wayland && ! use headless && has_version "x11-drivers/nvidia-drivers"; then
		ewarn "Proprietary nVidia driver does not work correctly with Ozone. You might be"
		ewarn "able to work around this problem by using SwiftShader OpenGL implementation."
		ewarn "Add --use-gl=swiftshader to CHROMIUM_FLAGS in /etc/chromium/default to force SwiftShader."
	fi
}

src_prepare() {
	use custom-cflags || rm "${WORKDIR}/patches/chromium-90-compiler.patch" || die

	#rm "${WORKDIR}/patches/chromium-84-blink-disable-clang-format.patch" || die

	local p="${FILESDIR}/chromium-$(ver_cut 1-1)"

	local PATCHES=(
		"${WORKDIR}/patches"
		"${p}/chromium-89-EnumTable-crash.patch"
		"${p}/chromium-system-fix-shim-headers-r0.patch"

		# Extra patches taken from openSUSE and Arch
		"${p}/chromium_hevc_non_chromeos.patch"
		"${p}/force-mp3-files-to-have-a-start-time-of-zero.patch"
		"${p}/chromium-glibc-2.33.patch"
		"${p}/chromium-glibc-malloc.patch"
		"${p}/chromium-system-libusb-r0.patch"
		"${p}/chromium-libusb-interrupt-event-handler-r1.patch"
		"${p}/chromium-skia-harmony.patch"
		"${p}/chromium-fix-cfi-failures-with-unbundled-libxml.patch"

		# Personal patches
		"${p}/chromium-optional-dbus-r12.patch"
		"${p}/chromium-optional-atk-r2.patch"
		"${p}/chromium-optional-egl-r0.patch"
	)

	default

	mkdir -p third_party/node/linux/node-linux-x64/bin || die
	ln -s "${EPREFIX}"/usr/bin/node third_party/node/linux/node-linux-x64/bin/node || die

	use convert-dict && eapply "${p}/chromium-ucf-dict-utility.patch"

	if use system-icu; then
		eapply "${p}/chromium-system-icu.patch"
	fi

	if use system-jsoncpp; then
		eapply "${p}/chromium-system-jsoncpp-r2.patch"
		sed -i '/^#include "third_party\/jsoncpp.*$/{s//#include <json\/value\.h>/;h};${x;/./{x;q0};x;q1}' components/mirroring/service/receiver_response.h || die
		sed -i '/^.*json\/reader.h"$/{s//#include <json\/reader\.h>/;h};${x;/./{x;q0};x;q1}' components/mirroring/service/receiver_response.cc || die
		sed -i '/^.*json\/writer.h"$/{s//#include <json\/writer\.h>/;h};${x;/./{x;q0};x;q1}' components/mirroring/service/receiver_response.cc || die
	fi

	#if use system-libvpx; then
		##eapply "${p}/chromium-system-vpx-r1.patch"
		#has_version "=media-libs/libvpx-1.9*" && eapply "${p}/chromium-vpx-1.9-compatibility-r4.patch"
	#fi

	use system-openjpeg && eapply "${p}/chromium-system-openjpeg-r2.patch"

	if use vaapi; then
		#has_version "=x11-libs/libva-2.11.0" && eapply "${p}/chromium-fix-libva-redef.patch"
		eapply "${p}/chromium-86-fix-vaapi-on-intel.patch"
		elog "Even though ${PN} is built with vaapi support, #ignore-gpu-blacklist"
		elog "should be enabled via flags or commandline for it to work."
	fi

	use vdpau && eapply "${p}/vdpau-support-r3.patch"

	use system-libdrm && eapply "${p}/chromium-system-libdrm.patch"

	if use wayland; then
		eapply "${p}/wayland-egl.patch"
		eapply "${p}/chromium-76-v4l-fix-linking.patch"
	fi

	#Igalia
	p="${FILESDIR}/chromium-$(ver_cut 1-1)/igalia"

	eapply "${p}/0001-Reland-ozone-wayland-watch-fd-on-a-dedicated-thread.patch"
	eapply "${p}/0008-Fix-sandbox-Aw-snap-for-syscalls-403-and-407.patch"
	eapply "${p}/0010-avoid-link-latomic-failure-on-CentOS-8-host.patch"
	eapply "${p}/0012-Fix-font-rendering-with-glibc-2.33.patch"
	eapply "${p}/0001-nomerge-attribute-on-declaration-is-only-available-s.patch"

	use vaapi && eapply "${p}/0001-ozone-add-va-api-support-to-wayland.patch"

	if use "elibc_musl"; then
		p="${FILESDIR}/musl"
		eapply "${p}/musl-crashpad.patch"
		eapply "${p}/musl-default-pthread-stacksize.patch"
		eapply "${p}/musl-fixes.patch"
		eapply "${p}/musl-hacks.patch"
		eapply "${p}/musl-libc++.patch"
		eapply "${p}/musl-no-execinfo.patch"
		eapply "${p}/musl-no-getcontext.patch"
		eapply "${p}/musl-no-mallinfo.patch"
		eapply "${p}/musl-resolver.patch"
		eapply "${p}/musl-sandbox.patch"
		eapply "${p}/musl-stacktrace.patch"
		eapply "${p}/musl-sync.patch"
		eapply "${p}/musl-v8-monotonic-pthread-cont_timedwait.patch"
	fi

	# Hack for libusb stuff (taken from openSUSE)
	rm third_party/libusb/src/libusb/libusb.h || die
	cp -a "${EPREFIX}/usr/include/libusb-1.0/libusb.h" \
		third_party/libusb/src/libusb/libusb.h || die

	# From here we adapt ungoogled-chromium's patches to our needs
	local ugc_pruning_list="${UGC_WD}/pruning.list"
	local ugc_patch_series="${UGC_WD}/patches/series"

	local ugc_unneeded=(
		# GN bootstrap
		extra/debian/gn/parallel
	)
	use custom-cflags && ugc_unneeded+=(
		# part of chromium-$(ver_cut 1)-compiler.patch
		core/ungoogled-chromium/remove-enable-dse-memoryssa-cflag
	)

	local ugc_p ugc_dir
	for p in "${ugc_unneeded[@]}"; do
		einfo "Removing ${p}.patch"
		sed -i "\!${p}.patch!d" "${ugc_patch_series}" || die
	done

	if use js-type-check; then
		ewarn "Keeping binary compiler.jar in sources tree for js-type-check"
		sed -i "\!third_party/closure_compiler/compiler/compiler.jar!d" "${ugc_pruning_list}" || die
	fi

	if use pgo; then
		ewarn "Keeping binary profile data in sources tree for pgo"
		sed -i "\!chrome/build/pgo_profiles/.*!d" "${ugc_pruning_list}" || die
    fi

	ebegin "Pruning binaries"
	"${UGC_WD}/utils/prune_binaries.py" -q . "${UGC_WD}/pruning.list"
	eend $? || die

	ebegin "Applying ungoogled-chromium patches"
	"${UGC_WD}/utils/patches.py" -q apply . "${UGC_WD}/patches"
	eend $? || die

	ebegin "Applying domain substitution"
	"${UGC_WD}/utils/domain_substitution.py" -q apply -r "${UGC_WD}/domain_regex.list" -f "${UGC_WD}/domain_substitution.list" -c build/domsubcache.tar.gz .
	eend $? || die

	local keeplibs=(
		base/third_party/cityhash
		base/third_party/double_conversion
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
		net/third_party/mozilla_security_manager
		net/third_party/nss
		net/third_party/quic
		net/third_party/uri_template
		third_party/abseil-cpp
		third_party/angle
		third_party/angle/src/common/third_party/base
		third_party/angle/src/common/third_party/smhasher
		third_party/angle/src/common/third_party/xxhash
		third_party/angle/src/third_party/compiler
		third_party/angle/src/third_party/libXNVCtrl
		third_party/angle/src/third_party/trace_event
		third_party/angle/src/third_party/volk
		third_party/apple_apsl
		third_party/axe-core
		third_party/blink
		third_party/boringssl
		third_party/boringssl/src/third_party/fiat
		third_party/breakpad
		third_party/breakpad/breakpad/src/third_party/curl
		third_party/brotli
		third_party/catapult
		third_party/catapult/common/py_vulcanize/third_party/rcssmin
		third_party/catapult/common/py_vulcanize/third_party/rjsmin
		third_party/catapult/third_party/beautifulsoup4
		third_party/catapult/third_party/html5lib-python
		third_party/catapult/third_party/polymer
		third_party/catapult/third_party/six
		third_party/catapult/tracing/third_party/d3
		third_party/catapult/tracing/third_party/gl-matrix
		third_party/catapult/tracing/third_party/jpeg-js
		third_party/catapult/tracing/third_party/jszip
		third_party/catapult/tracing/third_party/mannwhitneyu
		third_party/catapult/tracing/third_party/oboe
		third_party/catapult/tracing/third_party/pako
		third_party/ced
		third_party/cld_3
	)
	#use js-type-check &&
	keeplibs+=(
		third_party/closure_compiler
	)
	keeplibs+=(
		third_party/crashpad
		third_party/crashpad/crashpad/third_party/lss
		third_party/crashpad/crashpad/third_party/zlib
		third_party/crc32c
		third_party/cros_system_api
		third_party/dav1d
		third_party/dawn
		third_party/dawn/third_party/khronos
		third_party/depot_tools
		third_party/devscripts
		third_party/devtools-frontend
		third_party/devtools-frontend/src/front_end/third_party/acorn
		third_party/devtools-frontend/src/front_end/third_party/axe-core
		third_party/devtools-frontend/src/front_end/third_party/chromium
		third_party/devtools-frontend/src/front_end/third_party/codemirror
		third_party/devtools-frontend/src/front_end/third_party/fabricjs
		third_party/devtools-frontend/src/front_end/third_party/i18n
		third_party/devtools-frontend/src/front_end/third_party/intl-messageformat
		third_party/devtools-frontend/src/front_end/third_party/lighthouse
		third_party/devtools-frontend/src/front_end/third_party/lit-html
		third_party/devtools-frontend/src/front_end/third_party/lodash-isequal
		third_party/devtools-frontend/src/front_end/third_party/marked
		third_party/devtools-frontend/src/front_end/third_party/puppeteer
		third_party/devtools-frontend/src/front_end/third_party/wasmparser
		third_party/devtools-frontend/src/third_party
		third_party/dom_distiller_js
		third_party/eigen3
		third_party/emoji-segmenter
		third_party/farmhash
		third_party/fdlibm
		third_party/fft2d
		third_party/flatbuffers
	)
	use system-ffmpeg || keeplibs+=( third_party/ffmpeg third_party/opus )
	use system-harfbuzz || keeplibs+=(
		third_party/freetype
		third_party/harfbuzz-ng
	)
	use system-icu || keeplibs+=( third_party/icu )
	keeplibs+=(
		third_party/fusejs
		third_party/libgifcodec
		third_party/liburlpattern
		third_party/libzip
		third_party/gemmlowp
		third_party/google_input_tools
		third_party/google_input_tools/third_party/closure_library
		third_party/google_input_tools/third_party/closure_library/third_party/closure
		third_party/googletest
		third_party/harfbuzz-ng/utils
		third_party/hunspell
		third_party/iccjpeg
		third_party/inspector_protocol
		third_party/jinja2
	)
	use system-jsoncpp || keeplibs+=(
		third_party/jsoncpp
	)
	keeplibs+=(
		third_party/jstemplate
		third_party/khronos
		third_party/leveldatabase
		third_party/libXNVCtrl
		third_party/libaddressinput
		third_party/libaom
		third_party/libaom/source/libaom/third_party/fastfeat
		third_party/libaom/source/libaom/third_party/vector
		third_party/libaom/source/libaom/third_party/x86inc
		third_party/libavif
		third_party/libgav1
	)
	use system-libdrm || keeplibs+=(
		third_party/libdrm
		third_party/libdrm/src/include/drm
	)
	keeplibs+=(
		third_party/libjingle
		third_party/libphonenumber
		third_party/libsecret
		third_party/libsrtp
		third_party/libsync
		third_party/libudev
		third_party/libva_protected_content
	)
	use system-libvpx || keeplibs+=(
		third_party/libvpx
		third_party/libvpx/source/libvpx/third_party/x86inc
	)
	keeplibs+=(
		third_party/libwebm
		third_party/libx11
		third_party/libxcb-keysyms
		third_party/libxml/chromium
		third_party/libyuv
		third_party/llvm
		third_party/lottie
		third_party/lss
		third_party/lzma_sdk
		third_party/mako
		third_party/markupsafe
		third_party/mesa
		third_party/metrics_proto
		third_party/modp_b64
		third_party/nasm
		third_party/nearby
		third_party/neon_2_sse
	)
	#use optimize-webui &&
	keeplibs+=(
		third_party/node
		third_party/node/node_modules/polymer-bundler/lib/third_party/UglifyJS2
	)
	use system-openh264 || keeplibs+=( third_party/openh264 )
	keeplibs+=(
		third_party/one_euro_filter
		third_party/opencv
		third_party/openscreen
		third_party/openscreen/src/third_party/mozilla
		third_party/openscreen/src/third_party/tinycbor/src/src
		third_party/ots
	)
	use pdf && keeplibs+=(
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
	)
	#use perfetto &&
	keeplibs+=(
		third_party/perfetto
		third_party/perfetto/protos/third_party/chromium
	)
	keeplibs+=(
		third_party/pffft
		third_party/ply
		third_party/polymer
		third_party/private-join-and-compute
		third_party/private_membership
		third_party/protobuf
		third_party/protobuf/third_party/six
		third_party/pyjson5
		third_party/qcms
	)
	use system-re2 || keeplibs+=(
		third_party/re2
	)
	keeplibs+=(
		third_party/rnnoise
		third_party/s2cellid
		third_party/schema_org
		third_party/securemessage
		third_party/shell-encryption
		third_party/simplejson
		third_party/skia
		third_party/skia/include/third_party/skcms
		third_party/skia/include/third_party/vulkan
		third_party/skia/third_party/skcms
		third_party/skia/third_party/vulkan
		third_party/smhasher
		third_party/sqlite
	)
	use swiftshader && keeplibs+=(
		third_party/swiftshader
		third_party/swiftshader/third_party/astc-encoder
		third_party/swiftshader/third_party/llvm-subzero
		third_party/swiftshader/third_party/marl
		third_party/swiftshader/third_party/subzero
		third_party/swiftshader/third_party/SPIRV-Headers/include/spirv/unified1
		third_party/swiftshader/third_party/astc-encoder/Source
	)
	use tcmalloc && keeplibs+=(
		third_party/tcmalloc
	)
	keeplibs+=(
		third_party/tensorflow-text
		third_party/tflite
		third_party/tflite/src/third_party/eigen3
		third_party/tflite/src/third_party/fft2d
		third_party/tflite-support
		third_party/tint
		third_party/ruy
		third_party/ukey2
		third_party/usb_ids
		third_party/unrar
		third_party/usrsctp
		third_party/utf
		third_party/vulkan
		third_party/web-animations-js
		third_party/webdriver
		third_party/webrtc
		third_party/webrtc/common_audio/third_party/ooura
		third_party/webrtc/common_audio/third_party/spl_sqrt_floor
		third_party/webrtc/modules/third_party/fft
		third_party/webrtc/modules/third_party/g711
		third_party/webrtc/modules/third_party/g722
		third_party/webrtc/rtc_base/third_party/base64
		third_party/webrtc/rtc_base/third_party/sigslot
	)
	#use widevine &&
	keeplibs+=(
		third_party/widevine
	)
	keeplibs+=(
		third_party/woff2
		third_party/wuffs
		third_party/x11proto
		third_party/xcbproto
		third_party/xdg-utils
		third_party/zxcvbn-cpp
		third_party/zlib/google
		tools/grit/third_party/six
		url/third_party/mozilla
		v8/src/third_party/siphash
		v8/src/third_party/valgrind
		v8/src/third_party/utf8-decoder
		v8/third_party/inspector_protocol
		v8/third_party/v8
	)
	use system-libevent || keeplibs+=(
		base/third_party/libevent
	)
	use v4l2 && keeplibs+=(
		third_party/v4l-utils
	)
	use libcxx || keeplibs+=( buildtools/third_party/libc++ buildtools/third_party/libc++abi )
	use wayland && keeplibs+=(
		third_party/wayland
		third_party/wayland-protocols
	)

	keeplibs+=( # needed when use_aura=true
		third_party/minigbm
		third_party/speech-dispatcher
	)

	if use arm64 || use ppc64 ; then
		keeplibs+=( third_party/swiftshader/third_party/llvm-10.0 )
	fi
	# we need to generate ppc64 stuff because upstream does not ship it yet
	# it has to be done before unbundling.
	if use ppc64; then
		pushd third_party/libvpx >/dev/null || die
		mkdir -p source/config/linux/ppc64 || die
		./generate_gni.sh || die
		popd >/dev/null || die
	fi

	ebegin "Removing unneeded bundled libraries"

	python_setup

	# Remove most bundled libraries. Some are still needed.
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove

	eend $? || die
}

src_configure() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	local myconf_gn=()

	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX NM

	if use clang && ! tc-is-clang ; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		AR=llvm-ar #thinlto fails otherwise
		strip-unsupported-flags
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		AR=gcc-ar #just in case
		strip-unsupported-flags
	fi

	if tc-is-clang; then
		myconf_gn+=(
			"is_clang=true"
			"clang_use_chrome_plugins=false"
		)
	else
		myconf_gn+=( "is_clang=false" )
	fi

	# Define a custom toolchain for GN
	myconf_gn+=( "custom_toolchain=\"//build/toolchain/linux/unbundle:default\"" )

	if tc-is-cross-compiler; then
		tc-export BUILD_{AR,CC,CXX,NM}
		myconf_gn+=(
			"host_toolchain=\"//build/toolchain/linux/unbundle:host\""
			"v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\""
		)
	else
		myconf_gn+=( "host_toolchain=\"//build/toolchain/linux/unbundle:default\"" )
	fi

	myconf_gn+=(
		"use_allocator=$(usex tcmalloc \"tcmalloc\" \"none\")"
		"use_allocator_shim=$(usex tcmalloc $(usex elibc_musl false true) false)"
	)

	local gn_system_libraries=(
		flac
		fontconfig
		freetype
		libdrm
		libjpeg
		libpng
		libwebp
		libxml
		libxslt
	)
	use system-openh264 && gn_system_libraries+=(
		openh264
	)
	use system-re2 && gn_system_libraries+=(
		re2
	)
	gn_system_libraries+=(
		snappy
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
	if use system-harfbuzz; then
		gn_system_libraries+=( freetype harfbuzz-ng )
	fi
	if use system-libevent; then
		gn_system_libraries+=( libevent )
	fi
	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" || die

	# See dependency logic in third_party/BUILD.gn
	myconf_gn+=( "use_system_harfbuzz=true" )

	# Disable deprecated libgnome-keyring dependency, bug #713012
	myconf_gn+=( "use_gnome_keyring=false" )

	# Optional dependencies.
	myconf_gn+=(
		"enable_js_type_check=$(usetf js-type-check)"
		"enable_hangout_services_extension=$(usetf hangouts)"
		"enable_widevine=$(usetf widevine)"
		"use_cups=$(usetf cups)"
		"use_kerberos=$(usetf kerberos)"
		"use_alsa=$(usetf alsa)"
		"use_pulseaudio=$(usetf pulseaudio)"
		"link_pulseaudio=$(usetf pulseaudio)"
		"enable_swiftshader=$(usetf swiftshader)"
		"use_swiftshader_with_subzero=$(usetf swiftshader)"
		"use_atk=$(usetf atk)"
		"has_native_accessibility=$(usetf atk)"
		"use_dbus=$(usetf dbus)"
		"use_udev=$(usetf udev)"
		"rtc_build_libevent=$(usetf udev)"
		"rtc_enable_libevent=$(usetf udev)"
		"use_v4l2_codec=$(usetf v4l2)"
		"use_v4lplugin=$(usetf v4lplugin)"
		"rtc_build_libvpx=$(usetf libvpx)"
		"media_use_libvpx=$(usetf libvpx)"
		"rtc_libvpx_build_vp9=$(usetf libvpx)"
		"enable_vulkan=$(usetf vulkan)"
		"angle_enable_vulkan=$(usetf vulkan)"
		"angle_enable_vulkan_validation_layers=$(usetf vulkan)"
		"angle_shared_libvulkan=$(usetf vulkan)"
		"use_gtk=$(usetf gtk)"
		"rtc_use_gtk=$(usetf gtk)"
		#"toolkit_uses_gtk=$(usetf gtk)" # Deprecated
		"rtc_use_x11=$(usetf X)"
		"use_x11=$(usetf X)"
		"angle_link_glx=$(usetf X)"
		"rtc_use_pipewire=$(usetf screencast)"
		#"rtc_pipewire_version=\"0.3\""
	)

	myconf_gn+=(
		"use_thin_lto=$(usetf thinlto)"
		"chrome_pgo_phase=$(usex pgo 2 0)"
		#"pgo_build=$(usetf pgo)"
		"thin_lto_enable_optimizations=$(usetf optimize-thinlto)"
		"optimize_webui=$(usetf optimize-webui)"
		#"use_openh264=$(usex system-openh264 false true)" #Encoding
		"rtc_use_h264=$(usetf proprietary-codecs)" #Decoding
		"enable_hls_sample_aes=true"
		"enable_mse_mpeg2ts_stream_parser=true"
		"enable_av1_decoder=true"
		"enable_platform_hevc=$(usetf proprietary-codecs)"
		"enable_platform_dolby_vision=$(usetf proprietary-codecs)"
		"enable_platform_ac3_eac3_audio=$(usetf proprietary-codecs)"
		"enable_platform_mpeg_h_audio=$(usetf proprietary-codecs)"
		"media_use_ffmpeg=true"
		"enable_ffmpeg_video_decoders=true"
		"proprietary_codecs=$(usetf proprietary-codecs)"
		"ffmpeg_branding=\"$(usex proprietary-codecs Chrome Chromium)\""
		"use_system_freetype=$(usetf system-harfbuzz)"
		"use_system_libopenjpeg2=$(usetf system-openjpeg)"
		"use_vaapi=$(usetf vaapi)"
		"enable_pdf=$(usetf pdf)"
		"use_system_lcms2=true"
		"enable_print_preview=true"
		#"enable_native_notifications=true"
		"use_gio=true"
		#"use_pic=$(usetf pic)"
		"is_component_ffmpeg=true"
		"use_low_quality_image_interpolation=false"
		"use_glib=$(usetf gtk)"
		"use_dawn=true"
		# Disable pseudolocales, only used for testing
		#"enable_pseudolocales=false"
	)

	# Disable nacl, we can't build without pnacl (http://crbug.com/269560).
	myconf_gn+=(
		"enable_nacl=false"
		"enable_nacl_nonsfi=false"
	)

	# Ungoogled flags
	myconf_gn+=(
		"enable_mdns=false"
		"enable_one_click_signin=false"
		"enable_reading_list=false"
		"enable_remoting=false"
		#"enable_media_remoting=false"
		"enable_reporting=false"
		"enable_service_discovery=false"
		"exclude_unwind_tables=true"
		"use_official_google_api_keys=false"
		"google_api_key=\"\""
		"google_default_client_id=\"\""
		"google_default_client_secret=\"\""
		"safe_browsing_mode=0"
		"use_unofficial_version_number=false"
		"is_official_build=true"
		"build_with_tflite_lib=false"
	)

	# Additional flags
	myconf_gn+=(
		"use_system_libjpeg=true"
		"use_system_zlib=true"
		"rtc_build_examples=false"
		"fieldtrial_testing_like_official_build=true"
		"use_gold=$(usetf gold)"
		"use_lld=$(usetf lld)"
		"use_sysroot=false"
		#"linux_use_bundled_binutils=false"
		"use_custom_libcxx=false"
		"use_xkbcommon=$(usetf xkbcommon)"
	)

	# Debug flags
	myconf_gn+=(
		"is_debug=$(usetf debug)"
		"symbol_level=$(usex debug 2 0)"
		"strip_debug_info=$(usex debug false true)"
		#"sanitizer_no_symbols=$(usex debug false true)"
		"blink_symbol_level=$(usex debug 2 0)"
		"enable_iterator_debugging=$(usetf debug)"
	)


	# Control Flow Integrity
	myconf_gn+=(
		"is_cfi=$(usetf cfi)"
		"use_cfi_icall=$(usex cfi $(usetf lld) false)" # use_cfi_icall only works with LLD and x86-64 arch
		"use_cfi_cast=$(usetf cfi)"
		"use_rtti=$(usetf cfi)"
	)

	if tc-is-cross-compiler; then
		tc-export BUILD_{AR,CC,CXX,NM}
		myconf_gn+=( "host_toolchain=\"//build/toolchain/linux/unbundle:host\"")
		myconf_gn+=( "v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\"")
	else
		myconf_gn+=( "host_toolchain=\"//build/toolchain/linux/unbundle:default\"")
	fi

	# ozone
	if use wayland; then
		myconf_gn+=(
			"use_ozone=true"
			"use_aura=true"
			"use_egl=true"
			#"is_desktop_linux=true"
			"ozone_auto_platforms=false"
			"ozone_platform_x11=$(usetf X)"
			"ozone_platform_wayland=$(usetf wayland)"
			"ozone_platform_headless=$(usetf headless)"
			"ozone_platform_gbm=false"
			#"use_bundled_weston=true" # not present
			#"enable_wayland_server=true" # for chromeos
			#"use_system_libwayland=$(usetf system-wayland)"
			"use_wayland_gbm=false"
			"enable_background_mode=true"
			#"system_wayland_scanner_path=/usr/bin/wayland-scanner" #chromeos
			"use_system_minigbm=false" # minigbm conflicts with mesa gbm
			"use_system_libdrm=$(usetf system-libdrm)"
			#"use_linux_v4l2_only=$(usetf v4l2)"
            #"toolkit_views=true"
		)
	else
		myconf_gn+=(
			"use_ozone=false"
			#"use_aura=false" # Can't build with aura disabled for X11+gtk build. Check ui/gfx/native_widget_types.h:195:2: error: #error Unknown build environment
            #"use_egl=false" # Aura req egl
		)
	fi

	local myarch="$(tc-arch)"

	# Avoid CFLAGS problems, bug #352457, bug #390147.
	if ! use custom-cflags; then
		filter-flags "-O*" "-Wl,-O*"; #See #25
		strip-flags

		# Prevent linker from running out of address space, bug #471810 .
		if use x86; then
			filter-flags "-g*"
		fi

		# Prevent libvpx build failures. Bug 530248, 544702, 546984.
		if use libvpx && [[ ${myarch} == amd64 || ${myarch} == x86 ]]; then
			filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2 -mno-fma -mno-fma4
		fi
	fi

	if use libcxx; then
		append-flags -stdlib=libc++
		append-ldflags -stdlib=libc++
	fi

	if [[ $myarch = amd64 ]] ; then
		myconf_gn+=( "target_cpu=\"x64\"" )
		ffmpeg_target_arch=x64
	elif [[ $myarch = x86 ]] ; then
		myconf_gn+=(
			"target_cpu=\"x86\""
			"v8_target_cpu=\"x86\""
		)
		ffmpeg_target_arch=ia32
		# This is normally defined by compiler_cpu_abi in
		# build/config/compiler/BUILD.gn, but we patch that part out.
		append-flags -msse2 -mfpmath=sse -mmmx
	elif [[ $myarch = arm64 ]] ; then
		myconf_gn+=(
			"target_cpu=\"arm64\""
			"v8_target_cpu=\"arm64\""
		)
		ffmpeg_target_arch=arm64
	elif [[ $myarch = arm ]] ; then
		myconf_gn+=(
			"target_cpu=\"arm\""
			"v8_target_cpu=\"arm\""
		)
		ffmpeg_target_arch=$(usex cpu_flags_arm_neon arm-neon arm)
	elif [[ $myarch = ppc64 ]] ; then
		myconf_gn+=(
			"target_cpu=\"ppc64\""
			"v8_target_cpu=\"ppc64\""
		)
		ffmpeg_target_arch=ppc64
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	if use thinlto; then
		# We need to change the default value of import-instr-limit in
		# LLVM to limit the text size increase. The default value is
		# 100, and we change it to 30 to reduce the text size increase
		# from 25% to 10%. The performance number of page_cycler is the
		# same on two of the thinLTO configurations, we got 1% slowdown
		# on speedometer when changing import-instr-limit from 100 to 30.
		#append-ldflags "-Wl,-plugin-opt,-import-instr-limit=30"
		append-ldflags "-Wl,--thinlto-jobs=$(makeopts_jobs)"
	fi

	# Make sure that -Werror doesn't get added to CFLAGS by the build system.
	# Depending on GCC version the warnings are different and we don't want
	# the build to fail because of that.
	myconf_gn+=( "treat_warnings_as_errors=false" )

	# Disable fatal linker warnings, bug 506268.
	myconf_gn+=( "fatal_linker_warnings=false" )

	# Bug 491582.
	export TMPDIR="${WORKDIR}/temp"
	mkdir -p -m 755 "${TMPDIR}" || die

	# https://bugs.gentoo.org/654216
	addpredict /dev/dri/ #nowarn

	#if ! use system-ffmpeg; then
	if false; then
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

	# Chromium relies on this, but was disabled in >=clang-10, crbug.com/1042470
	append-cxxflags $(test-flags-CXX -flax-vector-conversions=all)

	# Explicitly disable ICU data file support for system-icu builds.
	if use system-icu; then
		myconf_gn+=( "icu_use_data_file=false" )
	fi

	myconf_gn+=( "target_os=\"linux\"" )

	if tc-is-clang; then
		# Don't complain if Chromium uses a diagnostic option that is not yet
		# implemented in the compiler version used by the user. This is only
		# supported by Clang.
		append-flags -Wno-unknown-warning-option
	fi

	# Facilitate deterministic builds (taken from build/config/compiler/BUILD.gn)
	append-cflags -Wno-builtin-macro-redefined
	append-cxxflags -Wno-builtin-macro-redefined
	append-cppflags "-D__DATE__= -D__TIME__= -D__TIMESTAMP__="

	local flags
	einfo "Building with the following compiler settings:"
	for flags in C{C,XX} AR NM RANLIB {C,CXX,CPP,LD}FLAGS; do
		einfo "  ${flags} = \"${!flags}\""
	done

	einfo "Configuring Chromium..."
	set -- gn gen --args="${myconf_gn[*]} ${EXTRA_GN}" out/Release
	echo "$@"
	"$@" || die
}

src_compile() {
	# Final link uses lots of file descriptors.
	ulimit -n 2048

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	# https://bugs.gentoo.org/717456
	# Use bundled xcb-proto, because system xcb-proto doesn't have Python 2.7 support
	local -x PYTHONPATH="${WORKDIR}/setuptools-44.1.0:${PYTHONPATH+:}${PYTHONPATH}"

	use convert-dict && eninja -C out/Release convert_dict

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

	# Work around broken deps
	#eninja -C out/Release gen/ui/accessibility/ax_enums.mojom{,-shared}.h

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason.
	eninja -C out/Release chrome

	use chromedriver && eninja -C out/Release chromedriver
	use suid && eninja -C out/Release chrome_sandbox

	pax-mark m out/Release/chrome

	# Build manpage; bug #684550
	if use man; then
		sed -e 's|@@PACKAGE@@|chromium-browser|g;
		s|@@MENUNAME@@|Chromium|g;' \
		chrome/app/resources/manpage.1.in > \
		out/Release/chromium-browser.1 || die
	fi

	# Build desktop file; bug #706786
	if use xdg; then
		sed -e 's|@@MENUNAME@@|Chromium|g;
		s|@@USR_BIN_SYMLINK_NAME@@|chromium-browser|g;
		s|@@PACKAGE@@|chromium-browser|g;
		s|\(^Exec=\)/usr/bin/|\1|g;' \
		chrome/installer/linux/common/desktop.template > \
		out/Release/chromium-browser-chromium.desktop || die
	fi
}

src_install() {
	local CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome

	if use convert-dict; then
		newexe "${FILESDIR}/update-dicts.sh" update-dicts.sh
		doexe out/Release/convert_dict
	fi

	if use suid; then
		newexe out/Release/chrome_sandbox chrome-sandbox
		fperms 4755 "${CHROMIUM_HOME}/chrome-sandbox"
	fi

	use chromedriver && doexe out/Release/chromedriver

	local sedargs=( -e
			"s:/usr/lib/:/usr/$(get_libdir)/:g;
			s:@@OZONE_AUTO_SESSION@@:$(usex wayland true false):g;
			s:@@FORCE_OZONE_PLATFORM@@:$(usex headless true false):g"
	)
	sed "${sedargs[@]}" "${FILESDIR}/chromium-launcher-r6.sh" > chromium-launcher.sh || die

	doexe chromium-launcher.sh

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it; bug #355517.
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	use chromedriver && dosym "${CHROMIUM_HOME}/chromedriver" /usr/bin/chromedriver

	# Allow users to override command-line options, bug #357629.
	insinto /etc/chromium
	newins "${FILESDIR}/chromium.default" "default"

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd

	insinto "${CHROMIUM_HOME}"
	doins out/Release/*.bin
	doins out/Release/*.pak
	(
		shopt -s nullglob
		local files=(out/Release/*.so*)
		[[ ${#files[@]} -gt 0 ]] && doins "${files[@]}"
	)

	if ! use system-icu; then
		doins out/Release/icudtl.dat
	fi

	doins -r out/Release/locales
	doins -r out/Release/resources

	if [[ -d out/Release/swiftshader ]]; then
		insinto "${CHROMIUM_HOME}/swiftshader"
		doins out/Release/swiftshader/*.so*
	fi

	use widevine && dosym WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so ${CHROMIUM_HOME}/libwidevinecdm.so

	# Install icons
	local branding size
	for size in 16 24 32 48 64 128 256 ; do
		case ${size} in
			16|32) branding="chrome/app/theme/default_100_percent/chromium" ;;
				*) branding="chrome/app/theme/chromium" ;;
		esac
		newicon -s ${size} "${branding}/product_logo_${size}.png" \
			chromium-browser.png
	done

	if use xdg; then
		# Install desktop entry
		domenu out/Release/chromium-browser-chromium.desktop
		# Install GNOME default application entry (bug #303100).
		insinto /usr/share/gnome-control-center/default-apps
		newins "${FILESDIR}"/chromium-browser.xml chromium-browser.xml
	fi

	# Install manpage; bug #684550
	if use man; then
		doman out/Release/chromium-browser.1
		dosym chromium-browser.1 /usr/share/man/man1/chromium.1
	fi

	readme.gentoo_create_doc
}

pkg_postrm() {
	use xdg && xdg_icon_cache_update
	use xdg && xdg_desktop_database_update
}

pkg_postinst() {
	use xdg && xdg_icon_cache_update
	use xdg && xdg_desktop_database_update
	readme.gentoo_print_elog

	if use vaapi; then
		elog "VA-API is disabled by default at runtime. Either enable it"
		elog "by navigating to chrome://flags/#enable-accelerated-video-decode"
		elog "inside Chromium or add --enable-accelerated-video-decode"
		elog "to CHROMIUM_FLAGS in /etc/chromium/default."
	fi

	if use screencast; then
		elog "Screencast is disabled by default at runtime. Either enable it"
		elog "by navigating to chrome://flags/#enable-webrtc-pipewire-capturer"
		elog "inside Chromium or add --enable-webrtc-pipewire-capturer"
		elog "to CHROMIUM_FLAGS in /etc/chromium/default."
	fi

	if use widevine; then
		elog "widevine requires binary plugins, which are distributed separately"
		elog "Make sure you have www-plugins/chrome-binary-plugins installed"
	fi
}

usetf() {
	usex "$1" true false
}