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

option(DEBUG_PRINTOUT "Print out debug messages as gerbv process files" FALSE)

## Glib-2.0 and GTK-2.0
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-2.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)

## Gettext and intl
find_package(Gettext REQUIRED) # https://cmake.org/cmake/help/latest/module/FindGettext.html
find_package(Intl REQUIRED)
#pkg_check_modules(GetText REQUIRED IMPORTED_TARGET gettext)

include(GNUInstallDirs)
set(DATADIR "${CMAKE_INSTALL_FULL_DATADIR}/${CMAKE_PROJECT_NAME}")
set(LOCALEDIR "${CMAKE_INSTALL_FULL_LOCALEDIR}")
set(SCMSUBDIR "scheme")
set(BACKEND_DIR "${DATADIR}/${SCMSUBDIR}")

add_library(compilation-flags INTERFACE)
target_compile_options(compilation-flags INTERFACE -Wall -O3 -Wno-deprecated-declarations)
target_compile_options(compilation-flags INTERFACE $<$<CONFIG:Debug>:-g3>)
target_include_directories(compilation-flags INTERFACE ${GLIB_INCLUDE_DIRS} ${GTK_INCLUDE_DIRS} ${Intl_INCLUDE_DIRS})
target_link_directories(compilation-flags INTERFACE ${GLIB_LIBRARY_DIRS} ${GKT_LIBRARY_DIRS})
target_link_options(compilation-flags INTERFACE ${GLIB_LDFLAGS} ${GTK_LDFLAGS})
target_link_libraries(compilation-flags INTERFACE ${GLIB_LIBRARIES} ${GTK_LIBRARIES} Intl::Intl m)
## This is installation directory settings. These must be solved later by install target
target_compile_definitions(compilation-flags INTERFACE DATADIR="${DATADIR}")
target_compile_definitions(compilation-flags INTERFACE LOCALEDIR="${LOCALEDIR}")
target_compile_definitions(compilation-flags INTERFACE BINDIR="${CMAKE_INSTALL_FULL_BINDIR}")
target_compile_definitions(compilation-flags INTERFACE SCMSUBDIR="${SCMSUBDIR}")
target_compile_definitions(compilation-flags INTERFACE BACKEND_DIR="${BACKEND_DIR}")

add_subdirectory(config)
add_subdirectory(src)
