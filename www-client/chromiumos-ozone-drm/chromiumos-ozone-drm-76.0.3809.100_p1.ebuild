# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_{5,6,7}} )

CHROMIUM_LANGS="
	am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he hi hr hu id
	it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw ta te
	th tr uk vi zh-CN zh-TW
"

inherit git-r3 check-reqs chromium-2 desktop flag-o-matic ninja-utils pax-utils python-r1 readme.gentoo-r1 toolchain-funcs xdg-utils

UGC_PV="${PV/_p/-}"
UGC_P="ungoogled-chromium-${UGC_PV}"
UGC_WD="${WORKDIR}/${UGC_P}"
platform="linux-amd64"

DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://github.com/Eloston/ungoogled-chromium https://www.chromium.org/ https://github.com/Igalia/chromium"
SRC_URI="
	https://github.com/Eloston/ungoogled-chromium/archive/${UGC_PV}.tar.gz -> ${UGC_P}.tar.gz
	https://chrome-infra-packages.appspot.com/dl/gn/gn/${platform}/+/git_revision:b3fefa62b27278f19c25878b513e169b5ebcbc30 -> gn-linux-amd64.zip
	https://chrome-infra-packages.appspot.com/dl/chromium/third_party/checkstyle/+/y17J5dqst1qkBcbJyie8jltB2oFOgaQjFZ5k9UpbbbwC -> third_party-checkstyle.zip
	https://chrome-infra-packages.appspot.com/dl/gn/gn/${platform}/+/git_revision:81ee1967d3fcbc829bac1c005c3da59739c88df9 -> openscreen-gn-linux-amd64.zip
	https://chrome-infra-packages.appspot.com/dl/infra/tools/luci/isolate/${platform}/+/git_revision:25958d48e89e980e2a97daeddc977fb5e2e1fb8c -> isolate-linux-amd64.zip
	https://chrome-infra-packages.appspot.com/dl/infra/tools/luci/isolated/${platform}/+/git_revision:25958d48e89e980e2a97daeddc977fb5e2e1fb8c -> isolated-linux-amd64.zip
	https://chrome-infra-packages.appspot.com/dl/infra/tools/luci/swarming/${platform}/+/git_revision:25958d48e89e980e2a97daeddc977fb5e2e1fb8c -> swarming-linux-amd64.zip
	https://chrome-infra-packages.appspot.com/dl/skia/tools/goldctl/${platform}/+/git_revision:f87a7deecc778c67e04af82265f040fef5d05c3f	-> goldctl-linux-amd64.zip
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"
VIDEO_CARDS="
	amdgpu exynos intel marvell mediatek msm radeon radeonsi rockchip tegra vc4 virgl
"

IUSE="
	atk cfi component-build closure-compile cups custom-cflags +dbus gnome gold jumbo-build kerberos libcxx
	lld new-tcmalloc optimize-thinlto optimize-webui +pdf +proprietary-codecs
	pulseaudio selinux +suid system-ffmpeg system-harfbuzz +system-icu
	-system-jsoncpp +system-libevent +system-libvpx system-openh264
	+system-openjpeg +system-libdrm system-minigbm -system-wayland +tcmalloc +thinlto 
	vaapi widevine wayland X libvpx gtk xkbcommon v4l2 v4lplugin +clang swiftshader udev debug
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
RESTRICT="mirror
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
		x11-misc/xdg-utils:=
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
	vaapi? ( x11-libs/libva:= )
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
	virtual/ttf-fonts
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
		>=sys-devel/clang-8.0.0
		lld? ( >=sys-devel/lld-8.0.0 )
		>=sys-devel/llvm-8.0.0[gold?]
	)
	sys-devel/flex
	virtual/libusb:1
	virtual/pkgconfig
	cfi? ( >=sys-devel/clang-runtime-8.0.0[sanitize] )
	libcxx? (
		sys-libs/libcxx
		sys-libs/libcxxabi
	)
	lld? ( >=sys-devel/lld-8.0.0 )
	optimize-webui? ( >=net-libs/nodejs-7.6.0[inspector] )
"

# shellcheck disable=SC2086
if ! has chromium_pkg_die ${EBUILD_DEATH_HOOKS}; then
	EBUILD_DEATH_HOOKS+=" chromium_pkg_die";
fi

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS=""

PATCHES=(
	# Gentoo patches
	"${FILESDIR}/chromium-compiler-r10.patch"
	"${FILESDIR}/chromium-fix-char_traits.patch"
	"${FILESDIR}/chromium-angle-inline.patch"
	"${FILESDIR}/chromium-76-arm64-skia.patch"
	"${FILESDIR}/chromium-76-quiche.patch"
	"${FILESDIR}/chromium-76-gcc-vulkan.patch"
	"${FILESDIR}/chromium-76-gcc-private.patch"
	"${FILESDIR}/chromium-76-gcc-noexcept.patch"
	"${FILESDIR}/chromium-76-gcc-gl-init.patch"
	"${FILESDIR}/chromium-76-gcc-blink-namespace1.patch"
	"${FILESDIR}/chromium-76-gcc-blink-namespace2.patch"
	"${FILESDIR}/chromium-76-gcc-blink-constexpr.patch"
	"${FILESDIR}/chromium-76-gcc-uint32.patch"
	"${FILESDIR}/chromium-76-gcc-ambiguous-nodestructor.patch"
	"${FILESDIR}/chromium-76-gcc-include.patch"
	"${FILESDIR}/chromium-76-gcc-pure-virtual.patch"

	# Ungoogled patches
	"${FILESDIR}/ungoogled-chromium-disable-third-party-lzma-sdk-r0.patch"
	"${FILESDIR}/ungoogled-chromium-empty-array-r0.patch"
	"${FILESDIR}/ungoogled-chromium-libusb-interrupt-event-handler-r1.patch"
	"${FILESDIR}/ungoogled-chromium-system-libusb-r0.patch"
	"${FILESDIR}/ungoogled-chromium-system-fix-shim-headers-r0.patch"
	"${FILESDIR}/ungoogled-chromium-fix-nosafebrowsing-build-r0.patch"

	# Personal patches
 	"${FILESDIR}/chromium-optional-atk-r0.patch"
	"${FILESDIR}/chromium-optional-dbus-r8.patch"
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
	CHECKREQS_DISK_BUILD="7G"
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

src_unpack(){
	default

	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://chromium.googlesource.com/chromium/src.git"
	EGIT_COMMIT="refs/tags/${PV/_*/}"
	EGIT_CHECKOUT_DIR="${S}"
	#
	git-r3_src_unpack

	git-r3_fetch "https://chromium.googlesource.com/chromium/llvm-project/cfe/tools/clang-format.git" "96636aa0e9f047f17447f2d45a094d0b59ed7917"
	git-r3_checkout "https://chromium.googlesource.com/chromium/llvm-project/cfe/tools/clang-format.git" "${S}/buildtools/clang_format/script"

	git-r3_fetch "https://chromium.googlesource.com/chromium/llvm-project/libcxx.git" "5938e0582bac570a41edb3d6a2217c299adc1bc6"
	git-r3_checkout "https://chromium.googlesource.com/chromium/llvm-project/libcxx.git" "${S}/buildtools/third_party/libc++/trunk"

	git-r3_fetch "https://chromium.googlesource.com/chromium/llvm-project/libcxxabi.git" "0d529660e32d77d9111912d73f2c74fc5fa2a858"
	git-r3_checkout "https://chromium.googlesource.com/chromium/llvm-project/libcxxabi.git" "${S}/buildtools/third_party/libc++abi/trunk"

	git-r3_fetch "https://chromium.googlesource.com/external/llvm.org/libunwind.git" "69d9b84cca8354117b9fe9705a4430d789ee599b"
	git-r3_checkout "https://chromium.googlesource.com/external/llvm.org/libunwind.git" "${S}/buildtools/third_party/libunwind/trunk"

	git-r3_fetch "https://chromium.googlesource.com/media_router.git" "29324b698ccd8920bc81c71d42dadc6310f0ad0f"
	git-r3_checkout "https://chromium.googlesource.com/media_router.git" "${S}/chrome/browser/resources/media_router/extension/src"

	git-r3_fetch "https://chromium.googlesource.com/chromium/canvas_bench.git" "a7b40ea5ae0239517d78845a5fc9b12976bfc732"
	git-r3_checkout "https://chromium.googlesource.com/chromium/canvas_bench.git" "${S}/chrome/test/data/perf/canvas_bench"

	git-r3_fetch "https://chromium.googlesource.com/chromium/frame_rate/content.git" "c10272c88463efeef6bb19c9ec07c42bc8fe22b9"
	git-r3_checkout "https://chromium.googlesource.com/chromium/frame_rate/content.git" "${S}/chrome/test/data/perf/frame_rate/content"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/toji/webvr.info.git" "c58ae99b9ff9e2aa4c524633519570bf33536248"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/toji/webvr.info.git" "${S}/chrome/test/data/xr/webvr_info"

	git-r3_fetch "https://chromium.googlesource.com/chromium/cdm.git" "817c8005a57ea3ca417f767b3b3679601329afd8"
	git-r3_checkout "https://chromium.googlesource.com/chromium/cdm.git" "${S}/media/cdm/api"

	git-r3_fetch "https://chromium.googlesource.com/native_client/src/native_client.git" "0ddc033406886a709b901e0c312872529f9705e8"
	git-r3_checkout "https://chromium.googlesource.com/native_client/src/native_client.git" "${S}/native_client"

	git-r3_fetch "https://quiche.googlesource.com/quiche.git" "b417d60c04d847ac676aa4492c79a17fadca509e"
	git-r3_checkout "https://quiche.googlesource.com/quiche.git" "${S}/net/third_party/quiche/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git" "e7866de4b1dc2a7e8672867caeb0bdca49f458d3"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git" "${S}/third_party/SPIRV-Tools/src"

	git-r3_fetch "https://chromium.googlesource.com/angle/angle.git" "refs/heads/chromium/3809"
	git-r3_checkout "https://chromium.googlesource.com/angle/angle.git" "${S}/third_party/angle"

	git-r3_fetch "https://chromium.googlesource.com/external/deqp" "6859e6c3488a5c757557b42c3774508baeacf3d0"
	git-r3_checkout "https://chromium.googlesource.com/external/deqp" "${S}/third_party/angle/third_party/deqp/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/glmark2/glmark2" "c4b3ff5a481348e8bdc2b71ee275864db91e40b1"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/glmark2/glmark2" "${S}/third_party/angle/third_party/glmark2/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/Tencent/rapidjson" "7484e06c589873e1ed80382d262087e4fa80fb63"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/Tencent/rapidjson" "${S}/third_party/angle/third_party/rapidjson/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers" "982f0f84dccf6f281b48318c77261a9028000126"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers" "${S}/third_party/angle/third_party/vulkan-headers/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Loader" "2f0abfcf9eb04018e6e92125a70bc28665aa17fe"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Loader" "${S}/third_party/angle/third_party/vulkan-loader/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools" "f392e71b994036c92b896c2a62cc63d042b7f9b1"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools" "${S}/third_party/angle/third_party/vulkan-tools/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-ValidationLayers" "ff80a937c8a505abbdddb95d8ffaa446820c8391"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-ValidationLayers" "${S}/third_party/angle/third_party/vulkan-validation-layers/src"

	git-r3_fetch "https://boringssl.googlesource.com/boringssl.git" "2e0d354690064c90ee245c715b92e2bb32492571"
	git-r3_checkout "https://boringssl.googlesource.com/boringssl.git" "${S}/third_party/boringssl/src"

	git-r3_fetch "https://chromium.googlesource.com/breakpad/breakpad.git" "1fc9cc0d0e1dfafb8d29dba8d01f09587d870026"
	git-r3_checkout "https://chromium.googlesource.com/breakpad/breakpad.git" "${S}/third_party/breakpad/breakpad"

	git-r3_fetch "https://chromium.googlesource.com/catapult.git" "fa2fd31ebd189625ee47aacbf75aa7c217169c01"
	git-r3_checkout "https://chromium.googlesource.com/catapult.git" "${S}/third_party/catapult"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/compact_enc_det.git" "ba412eaaacd3186085babcd901679a48863c7dd5"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/compact_enc_det.git" "${S}/third_party/ced/src"

	git-r3_fetch "https://chromium.googlesource.com/chromiumos/chromite.git" "a9e9c3dff0c2bf41895f2c2c6fb10960cea00596"
	git-r3_checkout "https://chromium.googlesource.com/chromiumos/chromite.git" "${S}/third_party/chromite"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/cld_3.git" "06f695f1c8ee530104416aab5dcf2d6a1414a56a"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/cld_3.git" "${S}/third_party/cld_3/src"

	git-r3_fetch "https://chromium.googlesource.com/external/colorama.git" "799604a1041e9b3bc5d2789ecbd7e8db2e18e6b8"
	git-r3_checkout "https://chromium.googlesource.com/external/colorama.git" "${S}/third_party/colorama/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/crc32c.git" "5998f8451548244de8cde7fab387a550e7c4497d"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/crc32c.git" "${S}/third_party/crc32c/src"

	git-r3_fetch "https://chromium.googlesource.com/chromiumos/platform2/system_api.git" "a67d91d30a5a37cee98a9685f2082ecdf92168ad"
	git-r3_checkout "https://chromium.googlesource.com/chromiumos/platform2/system_api.git" "${S}/third_party/cros_system_api"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/videolan/dav1d.git" "fc3777b44c0449180073665eb78070d388b11738"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/videolan/dav1d.git" "${S}/third_party/dav1d/libdav1d"

	git-r3_fetch "https://dawn.googlesource.com/dawn.git" "26d3cf08c209c662a6e2298c301272e2eb8246e4"
	git-r3_checkout "https://dawn.googlesource.com/dawn.git" "${S}/third_party/dawn"

	git-r3_fetch "https://chromium.googlesource.com/chromium/tools/depot_tools.git" "bad01ad3adaaa017b780f020d85a1e3b34f89c98"
	git-r3_checkout "https://chromium.googlesource.com/chromium/tools/depot_tools.git" "${S}/third_party/depot_tools"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/ChromeDevTools/devtools-node-modules" "5f7cd2497d7a643125c3b6eb910d99ba28be6899"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/ChromeDevTools/devtools-node-modules" "${S}/third_party/devtools-node-modules"

	git-r3_fetch "https://chromium.googlesource.com/chromium/dom-distiller/dist.git" "3093c3e238768ab27ff756bd7563ccbb12129d9f"
	git-r3_checkout "https://chromium.googlesource.com/chromium/dom-distiller/dist.git" "${S}/third_party/dom_distiller_js/dist"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/googlei18n/emoji-segmenter.git" "9ba6d25d0d9313569665d4a9d2b34f0f39f9a50e"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/googlei18n/emoji-segmenter.git" "${S}/third_party/emoji-segmenter/src"

	#git-r3_fetch "https://chromium.googlesource.com/chromium/third_party/ffmpeg.git" "e1e3cc4d2ec19c4e1859e487e8b7529cb69d91d8"
	#git-r3_checkout "https://chromium.googlesource.com/chromium/third_party/ffmpeg.git" "${S}/third_party/ffmpeg"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/flac.git" "af862024c8c8fa0ae07ced05e89013d881b00596"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/flac.git" "${S}/third_party/flac"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/flatbuffers.git" "9bf9b18f0a705dfd6d50b98056463a55de6a1bf9"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/flatbuffers.git" "${S}/third_party/flatbuffers/src"

	git-r3_fetch "https://chromium.googlesource.com/external/fontconfig.git" "ba206df9b9a7ca300265f650842c1459ff7c634a"
	git-r3_checkout "https://chromium.googlesource.com/external/fontconfig.git" "${S}/third_party/fontconfig/src"

	git-r3_fetch "https://chromium.googlesource.com/chromium/src/third_party/freetype2.git" "12e4307dc7b48c9a4a4fc3ac6c32220874ab18ec"
	git-r3_checkout "https://chromium.googlesource.com/chromium/src/third_party/freetype2.git" "${S}/third_party/freetype/src"

	git-r3_fetch "https://chromium.googlesource.com/chromiumos/platform/gestures.git" "74f55100df966280d305d5d5ada824605f875839"
	git-r3_checkout "https://chromium.googlesource.com/chromiumos/platform/gestures.git" "${S}/third_party/gestures/gestures"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/glfw/glfw.git" "2de2589f910b1a85905f425be4d32f33cec092df"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/glfw/glfw.git" "${S}/third_party/glfw/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/glslang.git" "625eb25d6e801311af2f587a38ff35412876dfe0"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/glslang.git" "${S}/third_party/glslang/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/googletest.git" "f5edb4f542e155c75bc4b516f227911d99ec167c"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/googletest.git" "${S}/third_party/googletest/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/grpc/grpc.git" "b245ad4ae810ed6bc13378421edfd3986a8ffac3"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/grpc/grpc.git" "${S}/third_party/grpc/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/harfbuzz/harfbuzz.git" "c73d7ba75d4556d9b8e05b10d6572f74f4814f7a"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/harfbuzz/harfbuzz.git" "${S}/third_party/harfbuzz-ng/src"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/hunspell_dictionaries.git" "3874188bd69fe67a825d07584c74451e45063e95"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/hunspell_dictionaries.git" "${S}/third_party/hunspell_dictionaries"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/icu.git" "64e5d7d43a1ff205e3787ab6150bbc1a1837332b"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/icu.git" "${S}/third_party/icu"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/open-source-parsers/jsoncpp.git" "f572e8e42e22cfcf5ab0aea26574f408943edfa4"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/open-source-parsers/jsoncpp.git" "${S}/third_party/jsoncpp/source"

	git-r3_fetch "https://chromium.googlesource.com/external/leveldb.git" "4bd052d7e8b0469b2b87664388e2a99cb212ecdb"
	git-r3_checkout "https://chromium.googlesource.com/external/leveldb.git" "${S}/third_party/leveldatabase/src"

	git-r3_fetch "https://chromium.googlesource.com/chromium/llvm-project/compiler-rt/lib/fuzzer.git" "e9b95bcfe2f5472fac2e516a0040aedf2140dd62"
	git-r3_checkout "https://chromium.googlesource.com/chromium/llvm-project/compiler-rt/lib/fuzzer.git" "${S}/third_party/libFuzzer/src"

	git-r3_fetch "https://chromium.googlesource.com/external/libaddressinput.git" "56c60affb5de83c10ebf5f11d9adcdd70648ab71"
	git-r3_checkout "https://chromium.googlesource.com/external/libaddressinput.git" "${S}/third_party/libaddressinput/src"

	git-r3_fetch "https://aomedia.googlesource.com/aom.git" "625cded0550bb79efd10d98a9809a7ccd72a8f60"
	git-r3_checkout "https://aomedia.googlesource.com/aom.git" "${S}/third_party/libaom/source/libaom"

	git-r3_fetch "https://chromium.googlesource.com/chromiumos/third_party/libdrm.git" "0061b1f244574e615c415479725046ab2951f09a"
	git-r3_checkout "https://chromium.googlesource.com/chromiumos/third_party/libdrm.git" "${S}/third_party/libdrm/src"

	git-r3_fetch "https://chromium.googlesource.com/chromiumos/platform/libevdev.git" "9f7a1961eb4726211e18abd147d5a11a4ea86744"
	git-r3_checkout "https://chromium.googlesource.com/chromiumos/platform/libevdev.git" "${S}/third_party/libevdev/src"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/libjpeg_turbo.git" "2de84a43e683c2c3c8ff4922da16b9053f024144"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/libjpeg_turbo.git" "${S}/third_party/libjpeg_turbo"

	git-r3_fetch "https://chromium.googlesource.com/external/liblouis-github.git" "97ce1c67fccbd3668291b7e63c06161c095d49f2"
	git-r3_checkout "https://chromium.googlesource.com/external/liblouis-github.git" "${S}/third_party/liblouis/src"

	git-r3_fetch "https://chromium.googlesource.com/external/libphonenumber.git" "a4da30df63a097d67e3c429ead6790ad91d36cf4"
	git-r3_checkout "https://chromium.googlesource.com/external/libphonenumber.git" "${S}/third_party/libphonenumber/dist"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/libprotobuf-mutator.git" "439e81f8f4847ec6e2bf11b3aa634a5d8485633d"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/libprotobuf-mutator.git" "${S}/third_party/libprotobuf-mutator/src"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/libsrtp.git" "650611720ecc23e0e6b32b0e3100f8b4df91696c"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/libsrtp.git" "${S}/third_party/libsrtp"

	git-r3_fetch "https://chromium.googlesource.com/aosp/platform/system/core/libsync.git" "f4f4387b6bf2387efbcfd1453af4892e8982faf6"
	git-r3_checkout "https://chromium.googlesource.com/aosp/platform/system/core/libsync.git" "${S}/third_party/libsync/src"

	git-r3_fetch "https://chromium.googlesource.com/webm/libvpx.git" "0308a9a132612006056f9920c069a1942e49c26c"
	git-r3_checkout "https://chromium.googlesource.com/webm/libvpx.git" "${S}/third_party/libvpx/source/libvpx"

	git-r3_fetch "https://chromium.googlesource.com/webm/libwebm.git" "51ca718c3adf0ddedacd7df25fe45f67dc5a9ce1"
	git-r3_checkout "https://chromium.googlesource.com/webm/libwebm.git" "${S}/third_party/libwebm/source"

	git-r3_fetch "https://chromium.googlesource.com/libyuv/libyuv.git" "b36c86fdfe746d7be904c3a565b047b24d58087e"
	git-r3_checkout "https://chromium.googlesource.com/libyuv/libyuv.git" "${S}/third_party/libyuv"

	git-r3_fetch "https://chromium.googlesource.com/linux-syscall-support.git" "e6527b0cd469e3ff5764785dadcb39bf7d787154"
	git-r3_checkout "https://chromium.googlesource.com/linux-syscall-support.git" "${S}/third_party/lss"

	git-r3_fetch "https://chromium.googlesource.com/chromiumos/platform/minigbm.git" "4fe3038be586d5db8e44e452f5ed6a93c8ccf50a"
	git-r3_checkout "https://chromium.googlesource.com/chromiumos/platform/minigbm.git" "${S}/third_party/minigbm/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/nmoinvaz/minizip" "1ff40343b55e738d941abb51c70eddb803db16e2"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/nmoinvaz/minizip" "${S}/third_party/minizip/src"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/nasm.git" "c8b248039ec1f75a7c5733bbe76d7fa416ce097a"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/nasm.git" "${S}/third_party/nasm"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/cisco/openh264" "6f26bce0b1c4e8ce0e13332f7c0083788def5fdf"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/cisco/openh264" "${S}/third_party/openh264/src"

	git-r3_fetch "https://chromium.googlesource.com/openscreen" "6dcfbb6577554933548255799ed7b58bfbfc51fd"
	git-r3_checkout "https://chromium.googlesource.com/openscreen" "${S}/third_party/openscreen/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/intel/tinycbor.git" "bfc40dcf909f1998d7760c2bc0e1409979d3c8cb"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/intel/tinycbor.git" "${S}/third_party/openscreen/src/third_party/tinycbor/src"

	git-r3_fetch "https://pdfium.googlesource.com/pdfium.git" "refs/heads/chromium/3809"
	git-r3_checkout "https://pdfium.googlesource.com/pdfium.git" "${S}/third_party/pdfium"

	git-r3_fetch "https://android.googlesource.com/platform/external/perfetto.git" "7f727d4068ec466c3b1f3ba5f178fe2f58f1d1d7"
	git-r3_checkout "https://android.googlesource.com/platform/external/perfetto.git" "${S}/third_party/perfetto"

	git-r3_fetch "https://chromium.googlesource.com/chromiumos/third_party/pyelftools.git" "19b3e610c86fcadb837d252c794cb5e8008826ae"
	git-r3_checkout "https://chromium.googlesource.com/chromiumos/third_party/pyelftools.git" "${S}/third_party/pyelftools"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/pywebsocket.git" "2d7b73c3acbd0f41dcab487ae5c97c6feae06ce2"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/pywebsocket.git" "${S}/third_party/pywebsocket/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/quic-trace.git" "8415c22f0ca2485bd8a16eff64075f4361f3878e"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/quic-trace.git" "${S}/third_party/quic_trace/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/re2.git" "a98fad02c421896bc75d97f49ccd245cdce7dd55"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/re2.git" "${S}/third_party/re2/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/googlei18n/sfntly.git" "e24c73130c663c9f329e78f5ca3fd5bd83b02622"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/googlei18n/sfntly.git" "${S}/third_party/sfntly/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/shaderc.git" "538a9d21bcb7b3437f016337bf2ff262de26ea73"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/shaderc.git" "${S}/third_party/shaderc/src"

	git-r3_fetch "https://skia.googlesource.com/skia.git" "refs/heads/chrome/m76"
	git-r3_checkout "https://skia.googlesource.com/skia.git" "${S}/third_party/skia"

	git-r3_fetch "https://chromium.googlesource.com/external/smhasher.git" "e87738e57558e0ec472b2fc3a643b838e5b6e88f"
	git-r3_checkout "https://chromium.googlesource.com/external/smhasher.git" "${S}/third_party/smhasher/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/google/snappy.git" "3f194acb57e0487531c96b97af61dcbd025a78a3"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/google/snappy.git" "${S}/third_party/snappy/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross.git" "f07a4e16a60e1d0231dda5d3883550761bd70a47"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross.git" "${S}/third_party/spirv-cross/spirv-cross"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git" "7ac42f80c0e8a72eb0da29dbd673efad2b6cb421"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git" "${S}/third_party/spirv-headers/src"

	git-r3_fetch "https://swiftshader.googlesource.com/SwiftShader.git" "c0d7ee45d45f22772ceca9e961c1ab4cfc9322d9"
	git-r3_checkout "https://swiftshader.googlesource.com/SwiftShader.git" "${S}/third_party/swiftshader"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/sctplab/usrsctp" "7a8bc9a90ca96634aa56ee712856d97f27d903f8"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/sctplab/usrsctp" "${S}/third_party/usrsctp/usrsctplib"

	git-r3_fetch "https://chromium.googlesource.com/external/anongit.freedesktop.org/git/wayland/wayland-protocols.git" "57423eac60cc234ebfad15f394488a47f69afe16"
	git-r3_checkout "https://chromium.googlesource.com/external/anongit.freedesktop.org/git/wayland/wayland-protocols.git" "${S}/third_party/wayland-protocols/src"

	git-r3_fetch "https://chromium.googlesource.com/external/anongit.freedesktop.org/git/wayland/wayland.git" "1361da9cd5a719b32d978485a29920429a31ed25"
	git-r3_checkout "https://chromium.googlesource.com/external/anongit.freedesktop.org/git/wayland/wayland.git" "${S}/third_party/wayland/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/01org/wds" "ac3d8210d95f3000bf5c8e16a79dbbbf22d554a5"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/01org/wds" "${S}/third_party/wds/src"

	git-r3_fetch "https://chromium.googlesource.com/external/github.com/SeleniumHQ/selenium/py.git" "d0045ec570c1a77612db35d1e92f05e1d27b4d53"
	git-r3_checkout "https://chromium.googlesource.com/external/github.com/SeleniumHQ/selenium/py.git" "${S}/third_party/webdriver/pylib"

	git-r3_fetch "https://chromium.googlesource.com/external/khronosgroup/webgl.git" "6f0b34abee8dba611c253738d955c59f703c147a"
	git-r3_checkout "https://chromium.googlesource.com/external/khronosgroup/webgl.git" "${S}/third_party/webgl/src"

	git-r3_fetch "https://webrtc.googlesource.com/src.git" "refs/branch-heads/m76"
	git-r3_checkout "https://webrtc.googlesource.com/src.git" "${S}/third_party/webrtc"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/xdg-utils.git" "d80274d5869b17b8c9067a1022e4416ee7ed5e0d"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/xdg-utils.git" "${S}/third_party/xdg-utils"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/yasm/patched-yasm.git" "720b70524a4424b15fc57e82263568c8ba0496ad"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/yasm/patched-yasm.git" "${S}/third_party/yasm/source/patched-yasm"

	git-r3_fetch "https://chromium.googlesource.com/chromium/deps/acid3.git" "6be0a66a1ebd7ebc5abc1b2f405a945f6d871521"
	git-r3_checkout "https://chromium.googlesource.com/chromium/deps/acid3.git" "${S}/tools/page_cycler/acid3"

	git-r3_fetch "https://chromium.googlesource.com/infra/luci/client-py.git" "779c4f0f8488c64587b75dbb001d18c3c0c4cda9"
	git-r3_checkout "https://chromium.googlesource.com/infra/luci/client-py.git" "${S}/tools/swarming_client"

	git-r3_fetch "https://chromium.googlesource.com/v8/v8.git" "refs/heads/7.6-lkgr"
	git-r3_checkout "https://chromium.googlesource.com/v8/v8.git" "${S}/v8"
	
	git-r3_fetch "https://chromium.googlesource.com/chromium/third_party/ffmpeg.git" "7e1e8a4f7df474a4f8109c507a09621acad40314"
	git-r3_checkout "https://chromium.googlesource.com/chromium/third_party/ffmpeg.git" "${S}/third_party/ffmpeg"

	cp "${WORKDIR}/gn" "${S}/buildtools/linux64" || die
	mv "${WORKDIR}/checkstyle-8.0-all.jar" "${S}/third_party/checkstyle" || die
	mv "${WORKDIR}/gn" "${S}/third_party/openscreen/src/buildtools/linux64" || die
	mv "${WORKDIR}/isolate" "${S}/tools/luci-go" || die
	mv "${WORKDIR}/isolated" "${S}/tools/luci-go" || die
	mv "${WORKDIR}/swarming" "${S}/tools/luci-go" || die
	mv "${WORKDIR}/goldctl" "${S}/tools/skia_goldctl" || die
}

src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python3*'

	default

	if use "system-jsoncpp" ; then
		eapply "${FILESDIR}/chromium-system-jsoncpp-r0.patch" || die
	fi

	if use "system-openjpeg" ; then
		eapply "${FILESDIR}/chromium-system-openjpeg-r0.patch" || die
	fi

	if use optimize-webui; then
		mkdir -p third_party/node/linux/node-linux-x64/bin || die
		ln -s "${EPREFIX}/usr/bin/node" \
			third_party/node/linux/node-linux-x64/bin/node || die
	fi
	
	# Apply extra patches (taken from Igalia)
	local p="${FILESDIR}/igalia-$(ver_cut 1-1)"

	eapply "${p}/0001-ozone-wayland-Fix-method-prototype-match.patch" || die
	eapply "${p}/V4L2/0001-Add-support-for-V4L2VDA-on-Linux.patch" || die
	eapply "${p}/V4L2/0002-Add-mmap-via-libv4l-to-generic_v4l2_device.patch" || die

	# Hack for libusb stuff (taken from openSUSE)
	rm third_party/libusb/src/libusb/libusb.h || die
	cp -a "${EPREFIX}/usr/include/libusb-1.0/libusb.h" \
		third_party/libusb/src/libusb/libusb.h || die

	use gold && eapply "${FILESDIR}/chromium-gold-r4.patch"

	use widevine && eapply "${FILESDIR}/chromium-widevine-r4.patch"

	use system-libdrm && eapply "${FILESDIR}/chromium-system-libdrm.patch"

	#ebegin "Pruning binaries"
	#"${UGC_WD}/utils/prune_binaries.py" . "${UGC_WD}/pruning.list"
	#eend $? || die

	ebegin "Applying ungoogled-chromium patches"
	"${UGC_WD}/utils/patches.py" apply . "${UGC_WD}/patches"
	eend $? || die

	ebegin "Applying domain substitution"
	"${UGC_WD}/utils/domain_substitution.py" apply -r "${UGC_WD}/domain_regex.list" -f "${UGC_WD}/domain_substitution.list" -c build/domsubcache.tar.gz .
	eend $? || die

	local keeplibs=(
		base/third_party/cityhash
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
		third_party/boringssl/src/third_party/sike
		third_party/boringssl/linux-x86_64/crypto/third_party/sike
		third_party/boringssl/linux-aarch64/crypto/third_party/sike
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
		third_party/crashpad/crashpad/third_party/lss
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
		third_party/lss
		third_party/lzma_sdk
		third_party/markupsafe
		third_party/mesa
		third_party/metrics_proto
		third_party/modp_b64
		third_party/nasm
		third_party/openscreen
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
		third_party/skia/include/third_party/skcms
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
	use system-minigbm || keeplibs+=( third_party/minigbm )
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
		"cros_host_is_clang=$(usetf clang)"
		"cros_v8_snapshot_is_clang=$(usetf clang)"

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
		"use_bundled_fontconfig=false"
		"use_system_lcms2=$(usetf pdf)"
		"use_system_libsync=true"
		#"use_system_libopenjpeg2=$(usetf system-openjpeg)"

		"use_system_zlib=true"
		#"rtc_build_json=$(usex system-jsoncpp false true)"
		"use_vaapi=$(usetf vaapi)"

		# Debug flags
		"is_debug=$(usetf debug)"
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
		"rtc_initialize_ffmpeg=true"
		"use_v4l2_codec=$(usetf v4l2)"
		"use_linux_v4l2_only=$(usetf v4l2)"
		"use_v4lplugin=$(usetf v4lplugin)"
		"rtc_build_libvpx=$(usetf libvpx)"
		"media_use_libvpx=$(usetf libvpx)"
		"rtc_libvpx_build_vp9=false"
		#"enable_runtime_media_renderer_selection=true"
		"enable_mpeg_h_audio_demuxing=true"
		"enable_vulkan=false"
		"use_vaapi=$(usetf vaapi)"
		"enable_plugins=true"
		"use_cras=false"
		"use_low_quality_image_interpolation=false"

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
	
	use gold || myconf_gn+=( "use_lld=true" )

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

	use system-jsoncpp && myconf_gn+=(
		"rtc_jsoncpp_root=\"/include/jsoncpp/json\""
		"rtc_build_json=false"
	)
	
	# wayland
	if use wayland; then
		myconf_gn+=(
			"use_egl=true"
			#"toolkit_views=true" 
			"use_system_libwayland=$(usetf system-wayland)"
			"use_ozone=true"
			"use_aura=true"
			"use_wayland_gbm=true"
			"ozone_auto_platforms=false"
			"ozone_platform_x11=$(usetf X)"
			"ozone_platform_wayland=true"
			"ozone_platform_headless=true"
			"ozone_platform_gbm=true"
			"ozone_platform=\"gbm\""
			"enable_mus=false"
			"enable_wayland_server=true" #Exo parts (aura shell)
			"enable_package_mash_services=true" #ChromeOS
			"enable_background_mode=true"
			#"use_system_minigbm=$(usetf system-minigbm)"
			"use_system_minigbm=false"
			"use_system_libdrm=$(usetf system-libdrm)"

			"use_intel_minigbm=$(usetf video_cards_intel)" 
			"use_radeon_minigbm=$(usetf video_cards_radeon)"
		   	"use_amdgpu_minigbm=$(usetf video_cards_amdgpu)"
			"use_exynos_minigbm=$(usetf video_cards_exynos)"
			"use_marvell_minigbm=$(usetf video_cards_marvell)"
			"use_mediatek_minigbm=$(usetf video_cards_mediatek)"
			"use_msm_minigbm=$(usetf video_cards_msm)"
			"use_rockchip_minigbm=$(usetf video_cards_rockchip)"
			"use_tegra_minigbm=$(usetf video_cards_tegra)"
			"use_vc4_minigbm=$(usetf video_cards_vc4)"
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

	myconf_gn+=" target_os=\"chromeos\""

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

	newexe "${FILESDIR}/chromium-launcher-r3.sh" chromium-launcher.sh
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
	newins "${FILESDIR}/chromium.default" "default"

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
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	use gnome && update_caches
}

pkg_postinst() {
	use gnome && update_caches
	readme.gentoo_print_elog
}
