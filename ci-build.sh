#!/bin/bash

# AppVeyor and Drone Continuous Integration for MSYS2
# Author: Renato Silva <br.renatosilva@gmail.com>
# Author: Qian Hong <fracting@gmail.com>

# Configure
cd "$(dirname "$0")"
source 'ci-library.sh'
mkdir artifacts
mkdir sourcepkg
git_config user.email 'ci@msys2.org'
git_config user.name  'MSYS2 Continuous Integration'
git remote add upstream 'https://github.com/r-windows/rtools-base'
git fetch --quiet upstream

# Install common build tools
pacman -Syyu --noconfirm
pacman --noconfirm --needed -S curl-ca-bundle pactoys curl bsdtar pkg-config git patch libtool make autoconf automake gcc findutils bison tar zip p7zip flex gettext wget texinfo

# Detect
list_commits  || failure 'Could not detect added commits'
list_packages || failure 'Could not detect changed files'
message 'Processing changes' "${commits[@]}"
test -z "${packages}" && success 'No changes in package recipes'
define_build_order || failure 'Could not determine build order'

# Build
message 'Building packages' "${packages[@]}"
#execute 'Updating system' update_system
execute 'Approving recipe quality' check_recipe_quality

for package in "${packages[@]}"; do
    execute 'Building binary' makepkg --noconfirm --noprogressbar --skippgpcheck --nocheck --syncdeps --rmdeps --cleanbuild
    execute 'Building source' makepkg --noconfirm --noprogressbar --skippgpcheck --allsource
    if [ "${package}" != "msys2-runtime" ]; then
        # Cannot hotswap runtime from this bash script using that runtime
        execute 'Installing' yes:pacman --noprogressbar --upgrade *.pkg.tar.zst
    fi
    execute 'Checking Binaries' find ./pkg -regex ".*\.\(exe\|dll\|a\|pc\)" || true
    mv "${package}"/*.pkg.tar.zst artifacts
    mv "${package}"/*.src.tar.gz sourcepkg
    unset package
done

# Deploy
cd artifacts || success 'All packages built successfully'
execute 'Generating pacman repository' create_pacman_repository "${PACMAN_REPOSITORY:-ci-build}"
repo-remove "${PACMAN_REPOSITORY}.db.tar.xz" "pacman-mirrors"
execute 'Generating build references'  create_build_references  "${PACMAN_REPOSITORY:-ci-build}"
execute 'SHA-256 checksums' sha256sum *
success 'All artifacts built successfully'
