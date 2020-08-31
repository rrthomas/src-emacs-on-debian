# Integrating Emacs built from source into Debian

https://rrthomas@github.com/rrthomas/src-emacs-on-debian

Maintainer: Reuben Thomas <rrt@sc3d.org>  
Author: Michael Olson <mwolson@members.fsf.org>  

N.B.: If you use this package, you should purge it before upgrading your
distribution, because otherwise it is likely to break the upgrade process:
the `emacs` binary may well depend on library versions that are removed by the
upgrade, and hence the emacsen-common hooks will fail!

This git repository contains some useful resources for integrating
Emacs built from source into Debian or derivatives like Ubuntu.

There are two parts to this kit:

1. You should run `debian-init.el` early in your Emacs startup process
   (I load it immediately after setting up `load-path`). It runs
   Debian’s Emacs init files.

2. `restore-emacs` should be run every time you update your Emacs
   installed from source (e.g. with `git pull`), from the top-level
   source directory. It runs `make install` in the current directory,
   fixes some symlinks, and installs `emacs-snapshot_1.0_all.deb`, a
   package which provides Emacs to satisfy the dependencies of other
   packages.

Also, see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=840793

In emacsen-common 2.0.8 at least (possibly earlier), and until the bug is
fixed, `/usr/lib/emacsen-common/packages/install/emacsen-common` must be
patched to make installation work; in emacsen-common 3.0.4 it’s at lines
14–15, which read:

```
(cd /usr/share/${flavor}/site-lisp
  ln -s ../../emacsen-common/debian-startup.el .)
```

   should be replaced with:

```
ln -s /usr/share/emacsen-common/debian-startup.el /usr/share/${flavor}/site-lisp/
```
