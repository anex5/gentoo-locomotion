# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_{5,6,7}} )

CHROMIUM_LANGS="
	am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he hi hr hu id
	it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw ta te
	th tr uk vi zh-CN zh-TW
"

inherit git-r3 check-reqs chromium-2 desktop eapi7-ver flag-o-matic multilib ninja-utils pax-utils portability python-r1 readme.gentoo-r1 toolchain-funcs xdg-utils

UGC_PV="907d2a3f55c02f566d317f2ce817615ad2350f75"
UGC_P="ungoogled-chromium-${UGC_PV}"
UGC_WD="${WORKDIR}/${UGC_P}"


DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://github.com/Eloston/ungoogled-chromium https://www.chromium.org/ https://github.com/Igalia/chromium"
SRC_URI="
	https://commondatastorage.googleapis.com/chromium-browser-official/chromium-${PV/_*}.tar.xz
	https://github.com/xsmile/ungoogled-chromium/archive/${UGC_PV}.tar.gz -> ${UGC_P}.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
VIDEO_CARDS="
	amdgpu exynos intel marvell mediatek msm radeon radeonsi rockchip tegra vc4 virgl
"

IUSE="
	cfi cups custom-cflags gnome gold jumbo-build kerberos lld new-tcmalloc
	+optimize-webui proprietary-codecs pulseaudio selinux +suid +system-ffmpeg
	+system-harfbuzz +system-icu +system-libevent +system-libvpx +system-openh264
	+system-openjpeg +system-jsoncpp system-libdrm +tcmalloc thinlto vaapi widevine wayland X atk dbus gtk 
	xkbcommon libcxx v4l2_codec v4lplugin +clang clang_tidy closure debug
"

for card in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${card}"
done

REQUIRED_USE="
	|| ( $(python_gen_useflags 'python3*') )
	|| ( $(python_gen_useflags 'python2*') )
	new-tcmalloc? ( tcmalloc )
	^^ ( gold lld )
	cfi? ( thinlto )
	clang_tidy? ( clang )
	libcxx? ( clang )
	thinlto? ( clang || ( gold lld ) )
	gtk? ( X )
	gnome? ( gtk dbus )
"
RESTRICT="
	!system-ffmpeg? ( proprietary-codecs? ( bindist ) )
	!system-openh264? ( bindist )
"

COMMON_DEPEND="
	app-arch/bzip2:=
	cups? ( >=net-print/cups-1.3.11:= )
	atk? ( 
		dev-libs/atk
		app-accessibility/at-spi2-atk:2
	)
	dev-libs/expat:=
	dev-libs/glib:2   
	system-jsoncpp? ( dev-libs/jsoncpp )
	system-icu? ( >=dev-libs/icu-59:= )
	system-libevent? ( dev-libs/libevent )
	>=dev-libs/libxml2-2.9.4-r3:=[icu]
	dev-libs/libxslt:=
	dev-libs/nspr:=
	>=dev-libs/nss-3.26:=
	>=dev-libs/re2-0.2016.11.01:=
	>=media-libs/alsa-lib-1.0.19:=
	media-libs/fontconfig:=
	system-harfbuzz? (
		media-libs/freetype:=
		>=media-libs/harfbuzz-2.0.0:0=[icu(-)]
	)
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	system-libvpx? ( >=media-libs/libvpx-1.7.0:=[postproc,svc] )
	system-openh264? ( >=media-libs/openh264-1.6.0:= )
	system-openjpeg? ( media-libs/openjpeg:2 )
	system-libdrm? ( x11-libs/libdrm )
	pulseaudio? ( media-sound/pulseaudio:= )
	system-ffmpeg? (
		>=media-video/ffmpeg-4:=
		|| (
			media-video/ffmpeg[-samba]
			>=net-fs/samba-4.5.16[-debug(-)]
		)
		media-libs/opus:=
	)
	dbus? ( sys-apps/dbus:= )
	sys-apps/pciutils:=
	virtual/udev
	vaapi? ( x11-libs/libva:= )
	xkbcommon? (
		x11-libs/libxkbcommon
		x11-misc/xkeyboard-config
	)
	libcxx? (
		sys-libs/libcxxabi
		sys-libs/libcxx
	)
	v4lplugin? ( media-libs/libv4lplugins )
	gtk? ( x11-libs/gtk+:3[X] )
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
	gnome? (
		x11-misc/xdg-utils   
	)
	app-arch/snappy:=
	media-libs/flac:=
	>=media-libs/libwebp-0.4.0:=
	sys-libs/zlib:=[minizip]
	kerberos? ( virtual/krb5 )
"
# For nvidia-drivers blocker (Bug #413637)
RDEPEND="${COMMON_DEPEND}
	virtual/opengl
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-chromium )
	tcmalloc? ( !<x11-drivers/nvidia-drivers-331.20 )
	!x86? ( widevine? ( www-plugins/chrome-binary-plugins[widevine(-)] ) )
	!www-client/chromium
	!www-client/ungoogled-chromium-bin
"

# dev-vcs/git (Bug #593476)
# sys-apps/sandbox - https://crbug.com/586444
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	>=app-arch/gzip-1.7
	dev-lang/perl
	!arm? (
		dev-lang/yasm
	)
	dev-util/gn
	>=dev-util/gperf-3.0.3
	>=dev-util/ninja-1.7.2
	>=net-libs/nodejs-7.6.0[inspector]
	sys-apps/hwids[usb(+)]
	>=sys-devel/bison-2.4.3	
	clang? (
		>=sys-devel/clang-7.0.0
		>=sys-devel/clang-runtime-7.0.0[sanitize]
		lld? ( >=sys-devel/lld-7.0.0 )
		>=sys-devel/llvm-7.0.0[gold?]
	)
	sys-devel/flex
	virtual/libusb:1
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
	"${FILESDIR}/ungoogled-chromium-compiler-r4.patch"
 	"${FILESDIR}/chromium-test-r0.patch"
	"${FILESDIR}/chromium-webrtc-r0.patch"
	"${FILESDIR}/chromium-memcpy-r0.patch"
	"${FILESDIR}/chromium-math.h-r0.patch"
	"${FILESDIR}/chromium-stdint.patch"
)

S="${WORKDIR}/chromium-${PV/_*}"

pre_build_checks() {
	# Check build requirements (Bug #541816)
	CHECKREQS_MEMORY="3G"
	CHECKREQS_DISK_BUILD="8G"
	if use custom-cflags; then
		if ( shopt -s extglob; is-flagq '-g?(gdb)?([1-9])' ); then
			CHECKREQS_DISK_BUILD="25G"
		fi
	fi
	check-reqs_pkg_setup
}

pkg_pretend() {
	pre_build_checks
}

pkg_setup() {
	pre_build_checks

	chromium_suid_sandbox_check_kernel_config
}

#DEPOT_TOOLS="${S}/third_party/depot_tools"   
#export PATH=${PATH}:${DEPOT_TOOLS}

src_unpack() {

	default
	
  	# build tools  
	
	# Prevents gclient from updating self.
	#export DEPOT_TOOLS_UPDATE=0
	# Prevent gclient metrics collection.
	#export DEPOT_TOOLS_METRICS=0

	#DEPOT_TOOLS_URI="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
	#einfo "Fetching depot_tools from googlesource"
	#git-r3_fetch ${DEPOT_TOOLS_URI} depot_tools
	#git-r3_checkout ${DEPOT_TOOLS_URI}

	EGIT_BRANCH="release-R71-11151.B"
	rm -r ${S}/third_party/libdrm/src
	LIBDRM_URI="https://chromium.googlesource.com/chromiumos/third_party/libdrm"
	einfo "Fetching libdrm from googlesource"
	git-r3_fetch ${LIBDRM_URI} 
	git-r3_checkout ${LIBDRM_URI} ${S}/third_party/libdrm/src

	rm -r ${S}/third_party/minigbm/src
	MINIGBM_URI="https://chromium.googlesource.com/chromiumos/platform/minigbm"
	einfo "Fetching minigbm from googlesource"
	git-r3_fetch ${MINIGBM_URI} 
	git-r3_checkout ${MINIGBM_URI} ${S}/third_party/minigbm/src 

} 

usetf() { usex $1 true false ; }

src_prepare() {
	if use custom-cflags; then
		ewarn
		ewarn "USE=custom-cflags bypass strip-flags; you are on your own."
		ewarn "Expect build failures. Don't file bugs using that unsupported USE flag!"
		ewarn
		sleep 5
	fi

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python3*'

	default

	mkdir -p third_party/node/linux/node-linux-x64/bin || die
	ln -s "${EPREFIX%/}/usr/bin/node" third_party/node/linux/node-linux-x64/bin/node || die

	# Fix build with harfbuzz-2 (Bug #669034)
	use system-harfbuzz && eapply "${FILESDIR}/chromium-harfbuzz-r0.patch"

	# Apply extra patches (taken from openSUSE)
	local ep
	for ep in "${FILESDIR}/extra-70"/*.patch; do
		eapply "${ep}"
	done

	# Hack for libusb stuff (taken from openSUSE)
	rm third_party/libusb/src/libusb/libusb.h || die
	cp -a "${EPREFIX%/}/usr/include/libusb-1.0/libusb.h" \
		third_party/libusb/src/libusb/libusb.h || die

	use gold && eapply "${FILESDIR}/ungoogled-chromium-gold-r0.patch"
	#use wayland && eapply "${FILESDIR}/chromium-70-ozone-gbm.patch"
	
	#eapply "${FILESDIR}/system-libdrm.patch" || die
	
	# From here we adapt ungoogled-chromium's patches to our needs
	local ugc_cli="${UGC_WD}/run_buildkit_cli.py"
	local ugc_config="${UGC_WD}/config_bundles/linux_rooted"
	local ugc_common_dir="${UGC_WD}/config_bundles/common"
	local ugc_rooted_dir="${UGC_WD}/config_bundles/linux_rooted"

	use widevine || sed -i '/inox-patchset\/chromium-widevine-r2.patch/d' "${ugc_common_dir}/patch_order.list" || die 

	# Remove unneeded ARM & GCC patches. Also, as we will use
	# dev-util/gn, remove redundant patches related to GN bootstrap
	sed -i \
		-e '/arm\/skia.patch/d' \
		-e '/arm\/gcc_skcms_ice.patch/d' \
		-e '/fixes\/alignof.patch/d' \
		-e '/fixes\/as-needed.patch/d' \
		-e '/fixes\/member-assignment.patch/d' \
		-e '/fixes\/sizet.patch/d' \
		-e '/warnings\/attribute.patch/d' \
		-e '/warnings\/enum-compare.patch/d' \
		-e '/warnings\/multichar.patch/d' \
		-e '/warnings\/null-destination.patch/d' \
		-e '/gn\/parallel.patch/d' \
		-e '/gn-bootstrap-remove-gn-gen.patch/d' \
		-e '/no-such-option-no-sysroot.patch/d' \
		"${ugc_common_dir}/patch_order.list" || die

	sed -i '/gn\/libcxx.patch/d' "${ugc_rooted_dir}/patch_order.list" || die

	# The licensing issue only matters to Debian folks, it also
	# depends on system icu (https://bugs.debian.org/900596)
	sed -i '/system\/convertutf.patch/d' "${ugc_rooted_dir}/patch_order.list" || die
	sed -i '/system\/icu.patch/d' "${ugc_rooted_dir}/patch_order.list" || die
	sed -i '/opensuse\/system-libdrm.patch/d' "${ugc_rooted_dir}/patch_order.list" || die

 	use system-jsoncpp || sed -i '/system\/jsoncpp.patch/d' "${ugc_rooted_dir}/pruning.list" || die
	use system-icu || sed -i '/common\/icudtl.dat/d' "${ugc_rooted_dir}/pruning.list" || die
	use system-libevent || sed -i '/system\/event.patch/d' "${ugc_rooted_dir}/patch_order.list" || die
	use system-libvpx || sed -i '/system\/vpx.patch/d' "${ugc_rooted_dir}/patch_order.list" || die
	use system-openjpeg && sed -i '/system\/nspr.patch/a debian_buster/system/openjpeg.patch' "${ugc_rooted_dir}/patch_order.list" || die

	if ! use vaapi; then
		sed -i '/chromium-vaapi-r18.patch/d' "${ugc_rooted_dir}/patch_order.list" || die
	else
		if has_version '<x11-libs/libva-2.0.0'; then
			sed -i '/build.patch/i ungoogled-chromium/linux/fix-libva1-compatibility.patch' \
				"${ugc_rooted_dir}/patch_order.list" || die
		fi
	fi

	ebegin "Pruning binaries"
	"${ugc_cli}" prune -b "${ugc_config}" ./
	eend $? || die

	ebegin "Applying ungoogled-chromium patches"
	"${ugc_cli}" patches apply -b "${ugc_config}" ./
	eend $? || die

	ebegin "Applying domain substitution"
	"${ugc_cli}" domains apply -b "${ugc_config}" -c domainsubcache.tar.gz ./
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
		buildtools/third_party/libc++
		buildtools/third_party/libc++abi
		chrome/third_party/mozilla_security_manager
		courgette/third_party
		net/third_party/http2
		net/third_party/mozilla_security_manager
		net/third_party/nss
		net/third_party/quic
		net/third_party/spdy
		net/third_party/uri_template
		third_party/WebKit
		third_party/abseil-cpp
		#third_party/analytics
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
		third_party/closure_compiler
		third_party/crashpad
		third_party/crashpad/crashpad/third_party/zlib
		third_party/crc32c
		third_party/cros_system_api
		third_party/devscripts
		third_party/dom_distiller_js
		third_party/fips181
		third_party/flatbuffers
		third_party/flot
		third_party/glslang
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
		third_party/lss
		third_party/lzma_sdk
		third_party/markupsafe
		third_party/mesa
		third_party/metrics_proto
		third_party/minigbm
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
		third_party/SPIRV-Tools
		third_party/spirv-tools-angle
		third_party/sqlite
		third_party/swiftshader
		third_party/swiftshader/third_party/llvm-subzero
		third_party/swiftshader/third_party/subzero
		third_party/ungoogled
		third_party/unrar
		third_party/usrsctp
		third_party/vulkan
		third_party/vulkan-validation-layers
		third_party/wayland
		third_party/wayland-protocols
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
		third_party/zlib/google
		url/third_party/mozilla
		v8/src/third_party/valgrind
		v8/src/third_party/utf8-decoder
		v8/third_party/inspector_protocol
		v8/third_party/v8

		# gyp -> gn leftovers
		third_party/adobe
		third_party/speech-dispatcher
		third_party/usb_ids
		third_party/xdg-utils
		third_party/yasm/run_yasm.py
	)
	
	use system-jsoncpp || keeplibs+=( third_party/jsoncpp )
	use system-ffmpeg || keeplibs+=( third_party/ffmpeg third_party/opus )
	use system-harfbuzz || keeplibs+=( third_party/freetype third_party/harfbuzz-ng )
	use system-icu || keeplibs+=( third_party/icu )
	use system-libevent || keeplibs+=( base/third_party/libevent )
	use system-libvpx || keeplibs+=( third_party/libvpx third_party/libvpx/source/libvpx/third_party/x86inc )
	use system-openh264 || keeplibs+=( third_party/openh264 )
	use system-openjpeg || keeplibs+=( third_party/pdfium/third_party/libopenjpeg20 )
	use tcmalloc && keeplibs+=( third_party/tcmalloc )

	# Remove most bundled libraries, some are still needed
	python_setup 'python2*'
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove || die
}

get_binutils_path_ld() {
	local ld_path=$(readlink -f $(which ld))
	local binutils_dir=$(dirname ${ld_path})
	echo -e "${binutils_dir}"
}

get_binutils_path_gold() {
	local binutils_dir=$(get_binutils_path_ld)
	echo -e "${binutils_dir%\/*}/lib/bfd_plugins"
}

# Handle all CFLAGS/CXXFLAGS/etc... munging here.
setup_compile_flags() {
	# Avoid CFLAGS problems (Bug #352457, #390147)
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		filter-flags "-g*"

		# Prevent libvpx build failures (Bug #530248, #544702, #546984)
		if [[ ${ARCH} == amd64 || ${ARCH} == x86 ]]; then
			filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2
		fi
	fi

	# -clang-syntax is a flag that enable us to do clang syntax checking on
	# top of building Chrome with gcc. Since Chrome itself is clang clean,
	# there is no need to check it again. And this flag has
	# nothing to do with USE=clang.
	use clang && filter-flags -clang-syntax 

	# Remove unsupported arm64 linker flag on arm32 builds.
	# https://crbug.com/889079
	use arm && filter-flags "-Wl,--fix-cortex-a53-843419"
	
	use video_cards_amdgpu && append-cppflags -DDRV_AMDGPU && export DRV_AMDGPU=1
	use video_cards_exynos && append-cppflags -DDRV_EXYNOS && export DRV_EXYNOS=1
	use video_cards_intel && append-cppflags -DDRV_I915 && export DRV_I915=1
	use video_cards_marvell && append-cppflags -DDRV_MARVELL && export DRV_MARVELL=1
	use video_cards_mediatek && append-cppflags -DDRV_MEDIATEK && export DRV_MEDIATEK=1
	use video_cards_msm && append-cppflags -DDRV_MSM && export DRV_MSM=1
	use video_cards_radeon && append-cppflags -DDRV_RADEON && export DRV_RADEON=1
	use video_cards_radeonsi && append-cppflags -DDRV_RADEON && export DRV_RADEON=1
	use video_cards_rockchip && append-cppflags -DDRV_ROCKCHIP && export DRV_ROCKCHIP=1
	use video_cards_tegra && append-cppflags -DDRV_TEGRA && export DRV_TEGRA=1
	use video_cards_vc4 && append-cppflags -DDRV_VC4 && export DRV_VC4=1
	use video_cards_virgl && append-cppflags -DDRV_VIRGL && export DRV_VIRGL=1

	# LLVM needs this when parsing profiles.
	# See README on https://github.com/google/autofdo
	# For ARM, we do not need this flag because we don't get profiles
	# from ARM machines. And it triggers an llvm assertion when thinlto
	# and debug fission is used together.
	# See https://bugs.llvm.org/show_bug.cgi?id=37255
	if use clang && ! use arm; then
		append-flags -fdebug-info-for-profiling
	fi
	
	# The .dwp file for x86 and arm exceeds 4GB limit. Adding this flag as a
	# workaround. The generated symbol files are the same with/without this
	# flag. See https://crbug.com/641188
	if use debug && ( use x86 || use arm ) && ! use clang; then
		append-cflags -femit-struct-debug-reduced
		append-cxxflags -femit-struct-debug-reduced
	fi
	
	if use thinlto; then
		#append-ldflags -fplugin=liblto_plugin.so
		# We need to change the default value of import-instr-limit in
		# LLVM to limit the text size increase. The default value is
		# 100, and we change it to 30 to reduce the text size increase
		# from 25% to 10%. The performance number of page_cycler is the
		# same on two of the thinLTO configurations, we got 1% slowdown
		# on speedometer when changing import-instr-limit from 100 to 30.
		# We need to further reduce it to 20 for arm to limit the size
		# increase to 10%.
		local thinlto_ldflag="-Wl,-plugin-opt,-import-instr-limit=30"
		if use arm; then
			thinlto_ldflag="-Wl,-plugin-opt,-import-instr-limit=20"
			append-ldflags "-gsplit-dwarf"
		fi
		append-ldflags "${thinlto_ldflag}"
	fi
	
	# Enable std::vector []-operator bounds checking (https://crbug.com/333391)
	append-cxxflags -D__google_stl_debug_vector=1
	
	# Don't complain if Chromium uses a diagnostic option that is not yet
	# implemented in the compiler version used by the user. This is only
	# supported by Clang.
	if use clang; then
		append-flags -Wno-unknown-warning-option
		# Facilitate deterministic builds (taken from build/config/compiler/BUILD.gn)
		append-cflags -Wno-builtin-macro-redefined
		append-cxxflags -Wno-builtin-macro-redefined
		append-cppflags "-D__DATE__= -D__TIME__= -D__TIMESTAMP__="
		if use libcxx; then
			append-cxxflags "-stdlib=libc++"
			append-ldflags "-stdlib=libc++"
		fi
		use debug && append-flags -fno-split-dwarf-inlining
	fi
	
	# Workaround: Disable fatal linker warnings with asan/gold builds.
	# See https://crbug.com/823936
	if use gold; then 
	    #append-ldflags "-fplugin=LLVMgold.so"
		append-ldflags "-Wl,--no-fatal-warnings"
	fi
	
	# Strip debug info
	use debug || append-ldflags "-s"
	
	local flags
	einfo "Building with the compiler settings:"
	for flags in {C,CXX,CPP,LD}FLAGS; do
		einfo "  ${flags} = ${!flags}"
	done
}

src_configure() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python2*'

	# Make sure the build system will use the right tools (Bug #340795)
	tc-export CXX CC AR AS NM RANLIB STRIP
	export CC=$(usex clang "${CBUILD}-clang" "$(tc-getBUILD_CC)")
	export CXX=$(usex clang "${CBUILD}-clang++" "$(tc-getBUILD_CXX)")
	export NM=$(tc-getBUILD_NM)

	# Use g++ as the linker driver.
	export LD="${CXX}"
	export LD_host=${CXX_host}
	
	# We need below change when USE="thinlto" is set. We set this globally
	# so that users can turn on the "use_thin_lto" in the simplechrome
	# flow more easily. We might be able to remve the dependency on use
	# clang because clang is the default compiler now.
	if use clang ; then
		export AR="llvm-ar"
		# USE=thinlto affects host build, we need to set host AR to
		# llvm-ar to make sure host package builds with thinlto.
		# crbug.com/731335
		export AR_host="llvm-ar"
		export RANLIB="llvm-ranlib"
	fi

	if use clang_tidy; then
		export WITH_TIDY=1
	fi

	# Use system-provided libraries
	# TODO: freetype -- remove sources (https://crbug.com/pdfium/733)
	# TODO: use_system_hunspell (upstream changes needed)
	# TODO: use_system_libsrtp (Bug #459932)
	# TODO: use_system_protobuf (Bug #525560)
	# TODO: use_system_ssl (https://crbug.com/58087)
	# TODO: use_system_sqlite (https://crbug.com/22208)

	local gn_system_libraries=(
		flac
		fontconfig
		libdrm
		libjpeg
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
	use system-harfbuzz && gn_system_libraries+=( freetype harfbuzz-ng )
	use system-icu && gn_system_libraries+=( icu )
	use system-libevent && gn_system_libraries+=( libevent )
	use system-libvpx && gn_system_libraries+=( libvpx )
	use system-openh264 && gn_system_libraries+=( openh264 )


	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" || die

	local myconf_gn=""
	myconf_gn+=" blink_symbol_level=$(usex debug 2 -1)"
	myconf_gn+=" enable_ac3_eac3_audio_demuxing=true"
	myconf_gn+=" enable_hangout_services_extension=false"
	myconf_gn+=" enable_hevc_demuxing=true"
	myconf_gn+=" enable_iterator_debugging=$(usetf debug)"
	myconf_gn+=" enable_mdns=false"
	myconf_gn+=" enable_mse_mpeg2ts_stream_parser=true"

	# Disable nacl, we can't build without pnacl (http://crbug.com/269560).
	myconf_gn+=" enable_nacl=false"
	myconf_gn+=" enable_nacl_nonsfi=false"
	myconf_gn+=" enable_one_click_signin=false"
	myconf_gn+=" enable_reading_list=false"
	myconf_gn+=" enable_remoting=false"
	myconf_gn+=" enable_reporting=false"
	myconf_gn+=" enable_service_discovery=false"
	myconf_gn+=" enable_swiftshader=false"
	myconf_gn+=" enable_widevine=$(usetf widevine)"
	myconf_gn+=" exclude_unwind_tables=true"
	myconf_gn+=" fatal_linker_warnings=false"
	myconf_gn+=" ffmpeg_branding=\"$(usex proprietary-codecs Chrome Chromium)\""
	myconf_gn+=" fieldtrial_testing_like_official_build=true"

	# Set up Google API keys, see http://www.chromium.org/developers/how-tos/api-keys .
	# Note: these are for Gentoo use ONLY. For your own distribution,
	# please get your own set of keys. Feel free to contact chromium@gentoo.org
	# for more info.
	#local google_api_key="AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc"
	#local google_default_client_id="329227923882.apps.googleusercontent.com"
	#local google_default_client_secret="vgKG0NNv7GoDpbtoFNLxCUXu"
	local google_api_key=""
	local google_default_client_id=""
	local google_default_client_secret=""
	myconf_gn+=" google_api_key=\"${google_api_key}\""
	myconf_gn+=" google_default_client_id=\"${google_default_client_id}\""
	myconf_gn+=" google_default_client_secret=\"${google_default_client_secret}\""
	myconf_gn+=" use_official_google_api_keys=false"

	# Clang features.
	#myconf_gn+=" is_asan=$(usetf asan)"
	myconf_gn+=" is_clang=$(usetf clang)"
	myconf_gn+=" clang_use_chrome_plugins=false"
	myconf_gn+=" use_thin_lto=$(usetf thinlto)"
	myconf_gn+=" use_lld=$(usetf lld)"
	myconf_gn+=" is_cfi=$(usetf cfi)"
	myconf_gn+=" use_cfi_cast=$(usetf cfi)"

	myconf_gn+=" is_debug=$(usetf debug)"
	myconf_gn+=" use_debug_fission=false"
	myconf_gn+=" closure_compile=$(usetf closure)"
	myconf_gn+=" remove_webcore_debug_symbols=$(usex debug false true)"
	myconf_gn+=" is_official_build=true"
	myconf_gn+=" optimize_webui=$(usetf optimize-webui)"
	myconf_gn+=" proprietary_codecs=$(usetf proprietary-codecs)"
	myconf_gn+=" safe_browsing_mode=0"
	myconf_gn+=" symbol_level=$(usex debug 2 -1)"

	myconf_gn+=" treat_warnings_as_errors=false"
	myconf_gn+=" use_gnome_keyring=false" # Deprecated by libsecret
	myconf_gn+=" use_jumbo_build=$(usetf jumbo-build)"
	myconf_gn+=" jumbo_file_merge_limit=4"

	myconf_gn+=" use_dbus=$(usetf dbus)"

	myconf_gn+=" rtc_use_gtk=$(usetf gtk)"
	myconf_gn+=" rtc_use_x11=$(usetf X)"

	myconf_gn+=" use_sysroot=false"
	myconf_gn+=" use_unofficial_version_number=false"

	# UGC's "linux_rooted" GN flags (config_bundles/linux_rooted/gn_flags.map)
	myconf_gn+=" custom_toolchain=\"//build/toolchain/linux/unbundle:default\""
	myconf_gn+=" gold_path=\"$(get_binutils_path_gold)\""
	myconf_gn+=" goma_dir=\"\""
	if tc-is-cross-compiler; then
		tc-export BUILD_{AR,CC,CXX,NM}
		myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:host\""
		myconf_gn+=" v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\""
	else
		myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:default\""
	fi
	myconf_gn+=" link_pulseaudio=$(usetf pulseaudio)"
	myconf_gn+=" linux_use_bundled_binutils=false"
	myconf_gn+=" optimize_for_size=false"
	myconf_gn+=" use_allocator=\"$(usex tcmalloc tcmalloc none)\""
	myconf_gn+=" use_new_tcmalloc=$(usetf new-tcmalloc)"
	myconf_gn+=" use_cups=$(usetf cups)"
	myconf_gn+=" use_custom_libcxx=false"
	myconf_gn+=" use_system_libcxx=$(usetf libcxx)"

	myconf_gn+=" use_gio=$(usetf gnome)"
	myconf_gn+=" use_gconf=$(usetf gnome)"

	myconf_gn+=" use_kerberos=$(usetf kerberos)"
	# If enabled, it will build the bundled OpenH264 for encoding,
	# hence the restriction: !system-openh264? ( bindist )
	myconf_gn+=" use_openh264=$(usetf !system-openh264)"
	myconf_gn+=" use_pulseaudio=$(usetf pulseaudio)"
	myconf_gn+=" use_cras=false"
    myconf_gn+=" use_system_jsoncpp=$(usetf system-jsoncpp)"
	myconf_gn+=" use_system_freetype=$(usetf system-harfbuzz)"
	myconf_gn+=" use_system_harfbuzz=$(usetf system-harfbuzz)"
	myconf_gn+=" use_system_lcms2=true"
	myconf_gn+=" use_system_libjpeg=true"
	myconf_gn+=" use_system_zlib=true"
	myconf_gn+=" use_vaapi=$(usetf vaapi)"
	myconf_gn+=" use_xkbcommon=$(usetf xkbcommon)"
	myconf_gn+=" use_v4l2_codec=$(usetf v4l2_codec)"
	myconf_gn+=" use_linux_v4l2=$(usetf v4l2_codec)"
	myconf_gn+=" use_v4lplugin=$(usetf v4lplugin)"

	# wayland
	if use wayland; then
		#myconf_gn+=" target_os=\"chromeos\""
		myconf_gn+=" toolkit_views=true" 
		myconf_gn+=" use_system_wayland=true"
		myconf_gn+=" use_ozone=true"
		myconf_gn+=" use_aura=true"
		myconf_gn+=" ozone_auto_platforms=false"
		myconf_gn+=" ozone_platform_x11=$(usetf X)"
		myconf_gn+=" ozone_platform_wayland=true"
		
		#myconf_gn+=" ozone_platform_drm=true"
		#myconf_gn+=" ozone_platform_gbm=true"
		#myconf_gn+=" ozone_platform_egltest=true"
		#myconf_gn+=" use_evdev_gestures=true"
		#myconf_gn+=" enable_package_mash_services=true"
		#myconf_gn+=" enable_xdg_shell=true"
		myconf_gn+=" enable_mus=true"

		myconf_gn+=" use_intel_minigbm=$(usetf video_cards_intel)" 
		myconf_gn+=" use_radeon_minigbm=$(usetf video_cards_radeon)"
	   	myconf_gn+=" use_amdgpu_minigbm=$(usetf video_cards_amdgpu)"
		myconf_gn+=" use_exynos_minigbm=$(usetf video_cards_exynos)"
		myconf_gn+=" use_marvell_minigbm=$(usetf video_cards_marvell)"
		myconf_gn+=" use_mediatek_minigbm=$(usetf video_cards_mediatek)"
		myconf_gn+=" use_msm_minigbm=$(usetf video_cards_msm)"
		myconf_gn+=" use_radeonsi_minigbm=$(usetf video_cards_radeonsi)"
		myconf_gn+=" use_rockchip_minigbm=$(usetf video_cards_rockchip)"
		myconf_gn+=" use_tegra_minigbm=$(usetf video_cards_tegra)"
		myconf_gn+=" use_vc4_minigbm=$(usetf video_cards_vc4)"
 
		myconf_gn+=" use_nouveau_minigbm=true" 
		myconf_gn+=" use_virgl_minigbm=$(usetf video_cards_virgl)" 
		myconf_gn+=" use_system_minigbm=false"
		myconf_gn+=" use_system_libdrm=$(usetf system-libdrm)"
		myconf_gn+=" is_desktop_linux=$(usetf dbus)"
		myconf_gn+=" enable_background_mode=true"
	fi

	if [[ "${ARCH}" = amd64 ]]; then
		myconf_gn+=" target_cpu=\"x64\""
	elif [[ "${ARCH}" = x86 ]]; then
		myconf_gn+=" target_cpu=\"x86\""
	else
		die "Failed to determine target arch, got '${ARCH}'."
	fi

	setup_compile_flags

	# Bug #491582
	export TMPDIR="${WORKDIR}/temp"
	mkdir -p -m 755 "${TMPDIR}" || die

	# But #654216
	addpredict /dev/dri/ #nowarn

	einfo "Configuring Chromium..."
	set -- gn gen --args="${myconf_gn} ${EXTRA_GN}" out/Release
	echo "$@"
	"$@" || die	
}

src_compile() {
	# Final link uses lots of file descriptors.
	ulimit -n 2048

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python2*'

	# Avoid falling back to preprocessor mode when sources contain time macros
	(has ccache ${FEATURES}) && export CCACHE_SLOPPINESS=time_macros

	# Work around broken deps
	eninja -C out/Release gen/ui/accessibility/ax_enums.mojom{,-shared}.h

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason
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

	newexe "${FILESDIR}/ungoogled-chromium-launcher-r3.sh" chromium-launcher.sh
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
	popd

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
		newicon -s ${size} "${branding}/product_logo_${size}.png" \
			chromium-browser.png
	done

	if use gnome; then
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
		sed -i "/^Exec/s/$/ %U/" "${ED%/}"/usr/share/applications/*.desktop || die

		# Install GNOME default application entry (Bug #303100)
	
		insinto /usr/share/gnome-control-center/default-apps
		doins "${FILESDIR}/chromium-browser.xml"
	fi

	readme.gentoo_create_doc
}

update_caches() {
	if type gtk-update-icon-cache &>/dev/null; then
		ebegin "Updating GTK icon cache"
		gtk-update-icon-cache "${EROOT}/usr/share/icons/hicolor"
		eend $?
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
