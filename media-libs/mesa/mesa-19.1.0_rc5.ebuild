# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_5 python3_6 python3_7 )

MESON_AUTO_DEPEND=no
 
inherit llvm meson flag-o-matic multilib-minimal pax-utils python-any-r1 toolchain-funcs

OPENGL_DIR="xorg-x11"

MY_P="${P/_/-}"

[[ ${PV/_rc*/} == ${PV} ]] || FOLDER+="/RC"
DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/mesa/mesa.git"
	EXPERIMENTAL="true"
	inherit git-r3
else
	SRC_URI="https://mesa.freedesktop.org/archive/${MY_P}.tar.xz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
fi


# Most of the code is MIT/X11.
# ralloc is LGPL-3
# GLES[2]/gl[2]{,ext,platform}.h are SGI-B-2.0
LICENSE="MIT LGPL-3 SGI-B-2.0"
SLOT="0"
KEYWORDS="*"
INTEL_CARDS="i915 i965 intel iris"
RADEON_CARDS="amdgpu radeon radeonsi"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} freedreno llvmpipe mach64 mga nouveau r128 radeonsi savage sis softpipe tdfx via virgl vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done
IUSE="${IUSE_VIDEO_CARDS}
	+classic debug dri drm +egl +gallium +gbm gles1 +gles2 +libglvnd +llvm 
	+nptl opencl pic selinux pax_kernel vaapi valgrind vdpau vulkan vulkan-overlay wayland xlib-glx X"

REQUIRED_USE="
	video_cards_amdgpu? ( llvm )
	video_cards_llvmpipe? ( llvm )
	gles1?  ( egl )
	gles2?  ( egl )
	vulkan? ( dri
			  || ( video_cards_i965 video_cards_iris video_cards_radeonsi )
			  video_cards_radeonsi? ( llvm ) )
	vulkan-overlay? ( vulkan )
	wayland? ( egl gbm )
	video_cards_freedreno?  ( gallium )
	video_cards_intel?  ( classic )
	video_cards_i915?   ( || ( classic gallium ) )
	video_cards_i965?   ( classic )
	video_cards_iris?   ( gallium )
	video_cards_nouveau? ( || ( classic gallium ) )
	video_cards_radeon? ( || ( classic gallium )
						  gallium? ( x86? ( llvm ) amd64? ( llvm ) ) )
	video_cards_radeonsi?   ( gallium llvm )
	video_cards_virgl? ( gallium )
	video_cards_vmware? ( gallium )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.97"
RDEPEND="
	>=dev-libs/expat-2.1.0-r3:=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8[${MULTILIB_USEDEP}]
	X? (
		!<x11-base/xorg-server-1.7
		>=x11-libs/libX11-1.6.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxshmfence-1.1:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXdamage-1.1.4-r1:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXxf86vm-1.1.3:=[${MULTILIB_USEDEP}]
		x11-libs/libXfixes:=[${MULTILIB_USEDEP}]
	)
	>=x11-libs/libxcb-1.13:=[${MULTILIB_USEDEP}]
	libglvnd? (
		media-libs/libglvnd[${MULTILIB_USEDEP}]
		!app-eselect/eselect-opengl
	)
	gallium? (
		llvm? (
			video_cards_radeonsi? (
				virtual/libelf:0=[${MULTILIB_USEDEP}]
			)
			video_cards_radeon? (
				virtual/libelf:0=[${MULTILIB_USEDEP}]
			)
		)
		opencl? (
					dev-libs/ocl-icd[khronos-headers,${MULTILIB_USEDEP}]
					dev-libs/libclc
					virtual/libelf:0=[${MULTILIB_USEDEP}]
				)
		vaapi? (
			>=x11-libs/libva-1.7.3:=[${MULTILIB_USEDEP}]
			video_cards_nouveau? ( !<=x11-libs/libva-vdpau-driver-0.7.4-r3 )
		)
		vdpau? ( >=x11-libs/libvdpau-1.1:=[${MULTILIB_USEDEP}] )
	)

	wayland? (
		>=dev-libs/wayland-1.15.0:=[${MULTILIB_USEDEP}]
		>=dev-libs/wayland-protocols-1.8
	)
	${LIBDRM_DEPSTRING}[video_cards_nouveau?,video_cards_vmware?,${MULTILIB_USEDEP}]

	video_cards_intel? (
		!video_cards_i965? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	)
	video_cards_i915? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	vulkan-overlay? ( dev-util/glslang:0=[${MULTILIB_USEDEP}] )

	llvm? ( virtual/libelf )
	dev-libs/libgcrypt
	virtual/udev
	${LIBDRM_DEPSTRING}
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-libs/libxml2
	sys-devel/bison
	sys-devel/flex
	sys-devel/gettext
	virtual/pkgconfig
	x11-base/xorg-proto
	llvm? ( sys-devel/llvm )
	valgrind? ( dev-util/valgrind )
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	$(python_gen_any_dep ">=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]")
"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.
#
# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 10.
# 3. Specify LLVM_MAX_SLOT, e.g. 9.
LLVM_MAX_SLOT="9"
LLVM_DEPSTR="
	|| (
		sys-devel/llvm:9[${MULTILIB_USEDEP}]
		sys-devel/llvm:8[${MULTILIB_USEDEP}]
		sys-devel/llvm:7[${MULTILIB_USEDEP}]
	)
	sys-devel/llvm:=[${MULTILIB_USEDEP}]
"
LLVM_DEPSTR_AMDGPU=${LLVM_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
CLANG_DEPSTR=${LLVM_DEPSTR//llvm/clang}
CLANG_DEPSTR_AMDGPU=${CLANG_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
RDEPEND="${RDEPEND}
	${CLANG_DEPSTR_AMDGPU}
	${LLVM_DEPSTR_AMDGPU}
"
unset {LLVM,CLANG}_DEPSTR{,_AMDGPU}

S="${WORKDIR}/${MY_P}"
EGIT_CHECKOUT_DIR=${S}

QA_WX_LOAD="
x86? (
	!pic? (
		usr/lib*/libglapi.so.0.0.0
		usr/lib*/libGLESv1_CM.so.1.0.0
		usr/lib*/libGLESv2.so.2.0.0
		usr/lib*/libGL.so.1.2.0
	)
)"

driver_list() {
	local drivers="$(sort -u <<< "${1// /$'\n'}")"
	echo "${drivers//$'\n'/,}"
}

src_prepare() {
	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi
	# FreeBSD 6.* doesn't have posix_memalign().
	if [[ ${CHOST} == *-freebsd6.* ]]; then
		sed -i \
			-e "s/-DHAVE_POSIX_MEMALIGN//" \
			configure.ac || die
	fi
	epatch "${FILESDIR}"/18.3-intel-limit-urb-size-for-SKL-KBL-CFL-GT1.patch
	# Don't apply intel BGRA internal format patch for VM build since BGRA_EXT is not a valid
	# internal format for GL context.
	if use !video_cards_virgl; then
		epatch "${FILESDIR}"/DOWNSTREAM-i965-Use-GL_BGRA_EXT-internal-format-for-B8G8R8A8-B8.patch
		epatch "${FILESDIR}"/CHROMIUM-st-mesa-Use-GL_BGRA_EXT-internal-format-for-B8G8R8A8.patch
	fi
	#epatch "${FILESDIR}"/intel-Add-support-for-Comet-Lake.patch
	#epatch "${FILESDIR}"/UPSTREAM-mesa-Expose-EXT_texture_query_lod-and-add-support-fo.patch
	default
}

src_configure() {
	tc-getPROG PKG_CONFIG pkg-config
	# Needs std=gnu++11 to build with libc++. crbug.com/750831
	append-cxxflags "-std=gnu++11"
	# For llvmpipe on ARM we'll get errors about being unable to resolve
	# "__aeabi_unwind_cpp_pr1" if we don't include this flag; seems wise
	# to include it for all platforms though.
	use video_cards_llvmpipe && append-flags "-rtlib=libgcc"
	if use !gallium && use !classic && use !vulkan; then
		ewarn "You enabled neither classic, gallium, nor vulkan "
		ewarn "USE flags. No hardware drivers will be built."
	fi

	local emesonargs=()

	if use classic; then
	# Configurable DRI drivers
		# Intel code
		dri_driver_enable video_cards_intel i965
		dri_driver_enable video_cards_i965 i965
		if ! use video_cards_i915 && \
			! use video_cards_i965; then
			dri_driver_enable video_cards_intel i915 i965
		fi
		# Nouveau code
		dri_driver_enable video_cards_nouveau nouveau
	fi
	if use gallium; then
	# Configurable gallium drivers
		gallium_enable video_cards_llvmpipe swrast
		gallium_enable video_cards_softpipe swrast
		# Intel code
		gallium_enable video_cards_iris iris
		# Only one i915 driver (classic vs gallium). Default to classic.
		if ! use classic; then
			gallium_enable video_cards_i915 i915
			if ! use video_cards_i915 && \
				! use video_cards_i965; then
				gallium_enable video_cards_intel i915
			fi
		fi
		# Nouveau code
		gallium_enable video_cards_nouveau nouveau
		# ATI code
		gallium_enable video_cards_radeon r300 r600
		gallium_enable video_cards_amdgpu radeonsi
		# Freedreno code
		gallium_enable video_cards_freedreno freedreno
		gallium_enable video_cards_virgl virgl

		gallium_enable video_cards_vmware svga

		if use video_cards_radeonsi ||
		   use video_cards_nouveau; then
			emesonargs+=($(meson_use vaapi gallium-va))
			use vaapi && emesonargs+=( -Dva-libs-path="${EPREFIX}"/usr/$(get_libdir)/va/drivers )
		else
			emesonargs+=(-Dgallium-va=false)
		fi

		if use video_cards_radeonsi ||
		   use video_cards_nouveau; then
			emesonargs+=($(meson_use vdpau gallium-vdpau))
		else
			emesonargs+=(-Dgallium-vdpau=false)
		fi
		# opencl stuff
		emesonargs+=(
			-Dgallium-opencl="$(usex opencl icd disabled)"
		)
	fi
	if use vulkan; then
		vulkan_enable video_cards_i965 intel
		vulkan_enable video_cards_intel intel
		vulkan_enable video_cards_amdgpu amd
	fi

	# x86 hardened pax_kernel needs glx-rts, bug 240956
	if [[ ${ABI} == x86 ]]; then
		emesonargs+=( $(meson_use pax_kernel glx-read-only-text) )
	fi

	# on abi_x86_32 hardened we need to have asm disable
	if [[ ${ABI} == x86* ]] && use pic; then
		emesonargs+=( -Dasm=false )
	fi

	emesonargs+=(-Dgallium-nine=false)
	emesonargs+=(-Dgallium-xa=false)
	emesonargs+=(-Dgallium-xvmc=false)


	LLVM_ENABLE=false
	if use llvm && use !video_cards_softpipe; then
		emesonargs+=( -Dshared-llvm=false )
		export LLVM_CONFIG=${SYSROOT}/usr/lib/llvm/bin/llvm-config-host
		LLVM_ENABLE=true
	fi
	local egl_platforms=""
	if use egl; then
		egl_platforms="surfaceless"
		if use drm; then
			egl_platforms="${egl_platforms},drm"
		fi
		if use wayland; then
			egl_platforms="${egl_platforms},wayland"
		fi
		if use X; then
			egl_platforms="${egl_platforms},x11"
		fi
	fi
	if use X; then
		glx="dri"
	else
		glx="disabled"
	fi
	append-flags "-UENABLE_SHADER_CACHE"
	emesonargs+=(
		-Dglx="${glx}"
		-Dllvm="${LLVM_ENABLE}"
		-Dplatforms="${egl_platforms}"
		-Dshared-glapi=true
		$(meson_use dri)
		$(meson_use egl)
		$(meson_use gbm)
		$(meson_use X gl)
		$(meson_use gles1)
		$(meson_use gles2)
		$(meson_use libglvnd glvnd)
		$(meson_use selinux)
		-Dvalgrind=$(usex valgrind auto false)
		-Ddri-drivers=$(driver_list "${DRI_DRIVERS[*]}")
		-Dgallium-drivers=$(driver_list "${GALLIUM_DRIVERS[*]}")
		-Dvulkan-drivers=$(driver_list "${VULKAN_DRIVERS[*]}")
		$(meson_use vulkan-overlay vulkan-overlay-layer)
		--buildtype $(usex debug debug release)
		-Db_ndebug=$(usex debug false true)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	# Remove redundant GLES headers
	#rm -f "${D}"/usr/include/{EGL,GLES2,GLES3,KHR}/*.h || die "Removing GLES headers failed."
	use libglvnd && rm -f "${D}"/usr/$(get_libdir)/libGLESv{1_CM,2}.so*

	dodir /usr/$(get_libdir)/dri
	insinto "/usr/$(get_libdir)/dri/"
	insopts -m0755
	# install the gallium drivers we use
	local gallium_drivers_files=( nouveau_dri.so r300_dri.so r600_dri.so msm_dri.so swrast_dri.so )
	for x in ${gallium_drivers_files[@]}; do
		if [ -f "${S}/$(get_libdir)/gallium/${x}" ]; then
			doins "${S}/$(get_libdir)/gallium/${x}"
		fi
	done
	# install classic drivers we use
	local classic_drivers_files=( i810_dri.so i965_dri.so nouveau_vieux_dri.so radeon_dri.so r200_dri.so )
	for x in ${classic_drivers_files[@]}; do
		if [ -f "${S}/$(get_libdir)/${x}" ]; then
			doins "${S}/$(get_libdir)/${x}"
		fi
	done
	# Set driconf option to enable S3TC hardware decompression
	insinto "/etc/"
	doins "${FILESDIR}"/drirc
}

# $1 - VIDEO_CARDS flag (check skipped for "--")
# other args - names of DRI drivers to enable
dri_driver_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		DRI_DRIVERS+=("$@")
	fi
}
gallium_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		GALLIUM_DRIVERS+=("$@")
	fi
}
vulkan_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		VULKAN_DRIVERS+=("$@")
	fi
}
