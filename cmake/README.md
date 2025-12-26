# Helper scripts for CMake

## Gettext_helpers.cmake
Downloaded from https://github.com/erri120/Gettext-CMake/blob/master/Gettext_helpers.cmake

Reading the blog post at https://erri120.github.io/posts/2022-05-05/

## GetGitVersion.cmake
Returns a version string from Git tags

From https://chromium.googlesource.com/external/github.com/google/benchmark/+/refs/tags/v1.4.1/cmake/GetGitVersion.cmake

## Packing.cmake
Setup for packing distributions like deb, rpm and NSIS.

### DEB
See https://decovar.dev/blog/2021/09/23/cmake-cpack-package-deb-apt/

Use as
```
cmake --preset linux-gnu-gcc
cmake --build --preset linux-gnu-gcc-release
cpack --preset deb
```

Uses `dpkg-shlibdeps` to get `set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS YES)` to work.
We have hardcoded the library dependencies when install directory is not `/usr` since
`dpkg-shlibdeps` can not handle that.

Requires Debian/Ubuntu package `dpkg-dev`.

To inspect the created package, use this (which unpacks it locally)
```
cd _packages/
dpkg-deb -R ./gerbv_4.0_amd64.deb ./package
tree ./package/
```

### RPM

Requires rpmbuild executable 
* Debian/Ubuntu package `rpm`.
* Fedora/Red Hat package `rpm-build`

Use as
```
cmake --preset linux-gnu-gcc
cmake --build --preset linux-gnu-gcc-release
cpack --preset rpm
```
