# Rtools Base [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-windows/rtools-base)](https://ci.appveyor.com/project/jeroen/rtools-base)

> Rtools40 msys2 runtime packages

A few core msys2 runtime packages that were altered from [upstream](https://github.com/alexpux/msys2-packages) msys2 to work better for R and CRAN.

These packages are only needed to build the rtools40 runtime environment itself, regular R users and package developers don't need to be concerned with this at all. The mingw-w64 toolchains and c/c++ libraries for building R and R packages are in the [rtools-packages](https://github.com/r-windows/rtools-packages) repository.

## How it Works

The Rtools40 runtime consists of subset of [msys2](https://www.msys2.org/) with a few alterations:

 - [pacman-mirrors](pacman-mirrors/PKGBUILD) points to our custom rtools repos
 - [gnupg](gnupg/PKGBUILD) uses gpg1 instead of the much heavier gpg2
 - [curl](curl/PKGBUILD) uses our custom [curl-ca-bundle](curl-ca-bundle/PKGBUILD) instead of the annoying [ca-certificates](https://github.com/Alexpux/MSYS2-packages/blob/master/ca-certificates/PKGBUILD)
 - [pacman](pacman/PKGBUILD) has been rebuild with the above.
 - [tar](tar/PKGBUILD) has some custom patch from BDR for backward compatibility with old rtools
 - [texinfo](texinfo/PKGBUILD) ships texinfo 5 because I couldn't figure out how to build R with texinfo 6
 - [libxml2](libxml2/PKGBUILD) disabled ICU which doesn't work on CRAN (Because Windows Vista)
 - [make](make/PKGBUILD) has a patch to find `sh` when called from cmd instead of bash

For the other msys2 packages in rtools (including dependencies of the above) we use upstream msys2 builds. This means we may need to rebuild our binaries when an upstream dependency has a major upgrades which breaks the dll ABI.

Finally note that `pacman` is fully statically linked so it has no dll dependencies. Make sure our custom version of `curl` is installed when building pacman because all curl settings will be hardcoded in `pacman.exe`.

## The CI system

These binaries are automatically downloaded when building the [rtools-installer](https://github.com/r-windows/rtools-installer) bundle.
