# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit eutils git-r3

DESCRIPTION="All in one tool for Information Gathering"
HOMEPAGE="https://fb.me/mohamed.riahi.official.account"

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/Moham3dRiahi/Th3inspector"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="
	dev-perl/JSON
	dev-lang/perl
	dev-vcs/git
"

src_prepare() {
	if [[ ${PV} == "9999" ]] ; then
		local ver="git-${EGIT_VERSION:0:6}"
		#sed -i "/^GITVER[[:space:]]*=/s:=.*:=${ver}:" mk/git.mk || die
		einfo "Producing ChangeLog from Git history"
		GIT_DIR="${S}/.git" git log >"${S}"/ChangeLog
	fi

	# Allow user patches to be applied without modifying the ebuild
	eapply_user
}

src_install() {
	rmdir -r /usr/share/Th3inspector
	dodir /usr/share/Th3inspector
	insinto /usr/share/Th3inspector
	doins Th3inspector.pl
	fperms 0700 /usr/share/Th3inspector/Th3inspector.pl
}

pkg_postinst() {
	if [ -f "/usr/share/Th3inspector/Th3inspector.pl" ]; then
		elog "You can execute tool by typing /usr/share/Th3inspector/Th3inspector.pl"
	else
		elog "Tool Cannot Be Installed On Your System! Use It As Portable !"
	fi
}
