#!/bin/bash
#
# Helper script to unify build logic between different operating systems. Can be
# executed like this from the main directory:
#
#     mc fedora_38 .mc/rebuild.sh
#     mc ubuntu_22.04 .mc/rebuild.sh
set -e

rm -rf build
/opt/configure.sh
cmake --build build
/opt/package.sh

