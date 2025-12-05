cmake_minimum_required(VERSION 3.28)

project(gerbv
        VERSION 4.0
        DESCRIPTION "Gerber Viewer"
        LANGUAGES C CXX)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_EXPORT_COMPILE_COMMANDS "ON")

## Glib-2.0 and GTK-2.0
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-2.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)

## DXF support library
pkg_check_modules(DXF IMPORTED_TARGET dxflib)

## Gettext and intl
find_package(Gettext REQUIRED) # https://cmake.org/cmake/help/latest/module/FindGettext.html
find_package(Intl) # Removed REQUIRED since it will fail on Mingw where it seems to be part of Gettext

include(GNUInstallDirs)
set(DATADIR "${CMAKE_INSTALL_FULL_DATADIR}/${CMAKE_PROJECT_NAME}")
set(LOCALEDIR "${CMAKE_INSTALL_FULL_LOCALEDIR}")
set(SCMSUBDIR "scheme")
set(BACKEND_DIR "${DATADIR}/${SCMSUBDIR}")

add_library(compilation-flags INTERFACE)
target_compile_options(compilation-flags INTERFACE -Wall -O3 -Wno-deprecated-declarations)
target_compile_options(compilation-flags INTERFACE $<$<CONFIG:Debug>:-g3>)
target_link_libraries(compilation-flags INTERFACE PkgConfig::GLIB PkgConfig::GTK m)
if(DXF_FOUND)
    target_link_libraries(compilation-flags INTERFACE PkgConfig::DXF)
endif()
if(Intl_FOUND)
    target_link_libraries(compilation-flags INTERFACE Intl::Intl)
endif()

## This is installation directory settings. These must be solved later by install target
target_compile_definitions(compilation-flags INTERFACE DATADIR="${DATADIR}")
target_compile_definitions(compilation-flags INTERFACE LOCALEDIR="${LOCALEDIR}")
target_compile_definitions(compilation-flags INTERFACE BINDIR="${CMAKE_INSTALL_FULL_BINDIR}")
target_compile_definitions(compilation-flags INTERFACE SCMSUBDIR="${SCMSUBDIR}")
target_compile_definitions(compilation-flags INTERFACE BACKEND_DIR="${BACKEND_DIR}")

include(GetGitVersion)
get_git_version(VERSION)

add_subdirectory(locale)
add_subdirectory(config)
add_subdirectory(src)
add_subdirectory(man)
add_subdirectory(desktop)

install(DIRECTORY example TYPE DOC) # Rename to examples
install(DIRECTORY share/ TYPE DATA)
