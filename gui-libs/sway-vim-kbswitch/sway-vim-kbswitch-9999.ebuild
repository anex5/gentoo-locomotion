# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
itoa@1.0.10
libswaykbswitch@0.2.0
proc-macro2@1.0.70
quote@1.0.33
ryu@1.0.16
serde@1.0.193
serde_derive@1.0.193
serde_json@1.0.108
swayipc@3.0.2
swayipc-types@1.3.1
syn@2.0.41
thiserror@1.0.51
thiserror-impl@1.0.51
unicode-ident@1.0.12
"

inherit cargo multilib-minimal rust-toolchain

DESCRIPTION="A library for controlling sway through its IPC interface"
HOMEPAGE="https://github.com/khaser/sway-vim-kbswitch"

EGIT_REPO_URI="https://github.com/khaser/sway-vim-kbswitch"
inherit git-r3

KEYWORDS="amd64 arm arm64 ~loong ~mips ~ppc64 ~riscv ~s390 ~sparc x86"

BDEPEND="
	|| (
		gui-wm/sway
		gui-wm/swayfx
	)
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD GPL-3 MIT Unicode-DFS-2016"
SLOT="0"
IUSE=""
RESTRICT="mirror"

#PATCHES=( "${FILESDIR}/${PN}-0.2.0-build-with-cargo.patch" )
DOCS=(
	README.md
	LICENSE.md
)

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_prepare() {
	default
	multilib_copy_sources
}

src_configure() {
	multilib-minimal_src_configure
}

multilib_src_configure() {
	append-flags "-fPIC"
}

src_compile() {
	multilib-minimal_src_compile
}

multilib_src_compile() {
	cargo_src_compile --target="$(rust_abi)"
}

multilib_src_install() {
	dolib.so "target/$(rust_abi)/release/libswaykbswitch.so"
	#dosym libswaykbswitch.so /usr/$(get_libdir)/libswaykbswitch.so.0.2.0
	QA_FLAGS_IGNORED+=" usr/$(get_libdir)/libswaykbswitch.so" # rust libraries don't use LDFLAGS
	einstalldocs
}
