# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="app-misc/klipper"
ACCT_USER_ID="368"
ACCT_USER_GROUPS=( dialout klipper uucp netdev tty )

acct-user_add_deps
