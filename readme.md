# Rtools Base [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-windows/rtools-base)](https://ci.appveyor.com/project/jeroen/rtools-base)

> Rtools Core Packages

Core msys2 packages that were altered from [upstream](https://github.com/alexpux/msys2-packages) msys2. These are for the rtools environment itself, they do not contain the Rtools toolchain or packages. 

## How it Works

The Rtools runtime consists of subset of [msys2](https://www.msys2.org/) with a few alterations:

 - [pacman-mirrors](pacman-mirrors/PKGBUILD) points to our custom rtools repos
 - [gnupg](gnupg/PKGBUILD) uses gpg1 instead of the much heaver gpg2
 - [curl](curl/PKGBUILD) uses our custom [curl-ca-bundle](curl-ca-bundle/PKGBUILD) instead of the annoying [ca-certificates](https://github.com/Alexpux/MSYS2-packages/blob/master/ca-certificates/PKGBUILD)
 - [pacman](pacman/PKGBUILD) has been rebuild with the above. Also we are still on 5.0.1.
 - [tar](tar/PKGBUILD) has some custom patch from BDR for backward compatibility with old rtools
 - [texinfo](texinfo/PKGBUILD) ships texinfo 5 because I couldn't figure out how to build R with texinfo 6
 - [libxml2](libxml2/PKGBUILD) disabled ICU support because it is a pain on WinBuilder (Windows Vista)
 - [make](make/PKGBUILD) has a patch to find `sh` when called from cmd instead of bash
 - [msys2-runtime](msys2-runtime/PKGBUILD) has a patch to make msys2 not alter the `R_ARCH` 

For the other msys2 packages in rtools (including dependencies of the above) we use upstream msys2 builds. This means we may need to rebuild our binaries when an upstream dependency has a major upgrades which breaks the dll ABI.

Finally note that `pacman` is fully statically linked so it has no dll dependencies. Make sure our custom version of `curl` is installed when building pacman because all curl settings will be hardcoded in `pacman.exe`.

## The CI system

The CI has been configured to build these packages using the latest existing Rtools installer and deploys to:

 - 32 bit: http://dl.bintray.com/rtools/i686/
 - 64 bit: http://dl.bintray.com/rtools/x86_64/

These binaries are automatically downloaded when building the [rtools-installer](https://github.com/r-windows/rtools-installer) bundle.
