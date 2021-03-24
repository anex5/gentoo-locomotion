gentoo-locomotion: Overlay for Gentoo Linux
----------------------------------

This overlay was created to maintain my custom ebuilds for packages not presented in main gentoo overlay.

**DISCLAIMER:** As I don't have the resources, nor the time to make stable
ebuilds in the same way Gentoo developers do, all ebuilds are permanently kept
in the _testing branch¹_. Thus, you should probably consider it to be _unsafe_
and treat it as such. Nevertheless, I try my best to follow Gentoo's QA
standards and keep everything up to date, as I use many of these packages in a
production environment.

> ¹ *If a package is in testing, it means that the developers feel that it is
functional, but has not been thoroughly tested. Users using the testing branch
might very well be the first to discover a bug in the package in which case they
should file a bug report to let the developers know about it.* —
[Gentoo's Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Portage#Testing)

## How to install the overlay
You can clone the repository and create `/etc/portage/repos.conf/gentoo-locomotion.conf`
with the following contents:

```ini
[gentoo-locomotion]
priority = 50
location = /path/to/local/gentoo-locomotion-overlay
auto-sync = yes
sync-type = git
sync-uri = https://github.com/anex5/gentoo-locomotion.git
```

> **Note:** I recommend that you manually install the overlay, as obviously you
will be pulling directly from the original source. If you use the automatic
installation described below, you will be pulling from
[gentoo's mirror](https://github.com/gentoo-mirror) service, in which from time
to time have [sync issues](https://bugs.gentoo.org/653472).

Alternatively, for automatic install, you must have
[app-eselect/eselect-repository](https://packages.gentoo.org/packages/app-eselect/eselect-repository)
or [app-portage/layman](https://packages.gentoo.org/packages/app-portage/layman)
installed on your system for this to work.

#### Using `eselect-repository`:
```
eselect repository enable gentoo-locomotion
```

#### Using `layman`:
```
layman -o https://raw.githubusercontent.com/anex5/gentoo-locomotion/master/layman.xml -fa gentoo-locomotion
```

> **Note:** To use the testing branch for particular packages, you must add the
package category and name (e.g., foo-bar/xyz) in `/etc/portage/package.accept_keywords`.
It is also possible to create a directory (with the same name) and list the
package in the files under that directory. Please see the
[Gentoo Wiki](https://wiki.gentoo.org/wiki/Ebuild_repository) for an expanded
overview of ebuilds and unofficial repositories for Gentoo.

To contribute bug reports for this overlay, you can open up a GitHub issue or send
me a pull request.
