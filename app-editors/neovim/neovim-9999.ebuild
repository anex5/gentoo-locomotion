# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# RelWithDebInfo sets -Og -g
CMAKE_BUILD_TYPE=Release
LUA_COMPAT=( lua5-{1..2} luajit )
inherit cmake lua-single optfeature xdg

DESCRIPTION="Vim-fork focused on extensibility and agility"
HOMEPAGE="https://neovim.io"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/neovim/neovim.git"
else
	SRC_URI="https://github.com/neovim/neovim/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~x86 ~x64-macos"
fi

LICENSE="Apache-2.0 vim"
SLOT="0"
IUSE="doc lint +lto +nvimpager test"

# Upstream say the test library needs LuaJIT
# https://github.com/neovim/neovim/blob/91109ffda23d0ce61cec245b1f4ffb99e7591b62/CMakeLists.txt#L377
REQUIRED_USE="${LUA_REQUIRED_USE} test? ( lua_single_target_luajit )"
# TODO: Get tests running
RESTRICT="!test? ( test ) mirror"

# Upstream build scripts invoke the Lua interpreter
BDEPEND="${LUA_DEPS}
	>=dev-util/gperf-3.1
	>=sys-devel/gettext-0.20.1
	virtual/libiconv
	virtual/libintl
	virtual/pkgconfig
"
# Check https://github.com/neovim/neovim/blob/master/third-party/CMakeLists.txt for
# new dependency bounds and so on on bumps (obviously adjust for right branch/tag).
# List of required tree-sitter parsers is taken from cmake.deps/deps.txt
DEPEND="${LUA_DEPS}
	>=dev-lua/luv-1.50.0[${LUA_SINGLE_USEDEP}]
	$(lua_gen_cond_dep '
		dev-lua/lpeg[${LUA_USEDEP}]
		dev-lua/mpack[${LUA_USEDEP}]
		dev-lua/busted[${LUA_USEDEP}]
	')
	$(lua_gen_cond_dep '
		dev-lua/LuaBitOp[${LUA_USEDEP}]
	' lua5-{1,2})
	>=dev-libs/libutf8proc-2.10.0:=[-cjk]
	>=dev-libs/libuv-1.50.0:=
	>=dev-libs/libvterm-0.3.3
	>=dev-libs/msgpack-3.0.0:=
	>=dev-libs/tree-sitter-0.25.3:=
	=dev-libs/tree-sitter-c-0.23*
	=dev-libs/tree-sitter-lua-0.3*
	=dev-libs/tree-sitter-markdown-0.4*
	=dev-libs/tree-sitter-query-0.5*
	=dev-libs/tree-sitter-vim-0.5*
	=dev-libs/tree-sitter-vimdoc-3*
	>=dev-libs/unibilium-2.1.2:0=
	lint? (
		dev-util/shellcheck
		dev-util/stylua
	)
"
RDEPEND="
	${DEPEND}
	app-eselect/eselect-vi
"
BDEPEND+="
	test? (
		$(lua_gen_cond_dep 'dev-lua/busted[${LUA_USEDEP}]')
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-9999-cmake_lua_version.patch"
	"${FILESDIR}/${PN}-9999-cmake-darwin.patch"
)

src_prepare() {
	use doc || ( sed -e '/^file(GLOB DOCFILES .*)$/,/^  DESTINATION .*nvim\/runtime\/syntax\/vim)$/d' -i runtime/CMakeLists.txt || die )

	# Use our system vim dir
	sed -e "/^# define SYS_VIMRC_FILE/s|\$VIM|${EPREFIX}/etc/vim|" \
		-i src/nvim/globals.h || die

	# https://forums.gentoo.org/viewtopic-p-8750050.html
	xdg_environment_reset
	cmake_src_prepare
}

src_configure() {
	# TODO: Investigate USE_BUNDLED, doesn't seem to be needed right now
	local mycmakeargs=(
		-DENABLE_LTO=$(usex lto)
		-DPREFER_LUA=$(usex lua_single_target_luajit no "$(lua_get_version)")
		-DLUA_PRG="${LUA}"
		#-DLUA_GEN_PRG="${ELUA}"
		-DUSE_BUNDLED_BUSTED=0
		-DCOMPILE_LUA=0
		# bug 906019: fix hardcoded usage of ccache
		-DCACHE_PRG=OFF
		-DCI_LINT=$(usex lint)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# install a default configuration file
	insinto /etc/vim
	doins "${FILESDIR}"/sysinit.vim

	# symlink tree-sitter parsers
	dodir /usr/share/nvim/runtime
	for parser in c lua markdown query vim vimdoc; do
		dosym ../../../../$(get_libdir)/libtree-sitter-${parser}.so /usr/share/nvim/runtime/parser/${parser}.so
	done

	# conditionally install a symlink for nvimpager
	if use nvimpager; then
		dosym ../share/nvim/runtime/scripts/less.sh /usr/bin/nvimpager
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "clipboard support" x11-misc/xsel x11-misc/xclip gui-apps/wl-clipboard
	optfeature "Python plugin support" dev-python/pynvim
	optfeature "Ruby plugin support" dev-ruby/neovim-ruby-client
	optfeature "remote/nvr support" dev-python/neovim-remote
}
