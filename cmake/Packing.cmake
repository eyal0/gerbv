# these are cache variables, so they could be overwritten with -D,
set(CPACK_PACKAGE_NAME ${PROJECT_NAME}
    CACHE STRING "The resulting package name"
)
# which is useful in case of packing only selected components instead of the whole thing
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Gerber file viewer (only RS 274 X format)"
    CACHE STRING "Package description for the package metadata"
)
set(CPACK_PACKAGE_VENDOR "https://github.com/gerbv/gerbv")

set(CPACK_VERBATIM_VARIABLES YES)

set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PACKAGE_NAME})
SET(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_SOURCE_DIR}/_packages")

# Version is set from git tags in CMakeLists.txt via GetGitVersion
# Override CPACK version with parsed git version
set(CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH})

# Store full git version string as metadata
# This includes commit hash and dirty flag: e.g., "v4.0.1-23-gabcd1234-dirty"
set(CPACK_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}\nGit version: ${GIT_VERSION}")

# Set resource files
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

# Package release/revision number (increment for packaging fixes without version changes)
# Use commit count from git for development builds, otherwise use "1"
if(DEFINED VERSION_SUFFIX AND NOT "${VERSION_SUFFIX}" STREQUAL "")
    # Development build - use commit count or mark as dirty
    if("${VERSION_SUFFIX}" MATCHES "^([0-9]+)-")
        # Has commit count: v4.0-23-gabcd1234 -> release "23"
        string(REGEX MATCH "^([0-9]+)" COMMIT_COUNT "${VERSION_SUFFIX}")
        set(CPACK_DEBIAN_PACKAGE_RELEASE "${COMMIT_COUNT}")
        set(CPACK_RPM_PACKAGE_RELEASE "${COMMIT_COUNT}")
    elseif("${VERSION_SUFFIX}" MATCHES "dirty")
        # Dirty working tree
        set(CPACK_DEBIAN_PACKAGE_RELEASE "0.dirty")
        set(CPACK_RPM_PACKAGE_RELEASE "0.dirty")
    else()
        set(CPACK_DEBIAN_PACKAGE_RELEASE "1")
        set(CPACK_RPM_PACKAGE_RELEASE "1")
    endif()
else()
    # Clean release build from exact tag
    set(CPACK_DEBIAN_PACKAGE_RELEASE "1")
    set(CPACK_RPM_PACKAGE_RELEASE "1")
endif()

# Automatic dependency detection via dpkg-shlibdeps only works with standard prefixes
# For non-standard install prefixes like /opt/*, we hardcode the dependencies
if(CPACK_PACKAGING_INSTALL_PREFIX MATCHES "^/opt/")
    # Hardcoded dependencies for Debian packages with /opt prefix
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libgtk2.0-0, libglib2.0-0, libcairo2, libc6, libdxflib3")
else()
    # Use automatic dependency detection for standard prefixes
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS YES) # Requires dpkg-shlibdeps
endif()
# RPM handles /opt prefixes better - automatic detection works via ldd
set(CPACK_RPM_PACKAGE_AUTOREQ YES)
set(CPACK_STRIP_FILES YES)

set(CPACK_PACKAGE_CONTACT "YOUR@E-MAIL.net")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "YOUR NAME")

# Debian package control scripts (for /opt installation integration)
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_SOURCE_DIR}/debian/postinst;${CMAKE_SOURCE_DIR}/debian/postrm"
)

# RPM package scriptlets (for /opt installation integration)
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/rpm/post.sh")
set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/rpm/postun.sh")

# package name for deb. If set, then instead of some-application-0.9.2-Linux.deb
# you'll get some-application_0.9.2_amd64.deb (note the underscores too)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)

# package name for rpm. If set, then instead of gerbv-4.0-Linux.rpm
# you'll get gerbv-4.0-1.x86_64.rpm (proper RPM naming convention)
set(CPACK_RPM_FILE_NAME RPM-DEFAULT)

# that is if you want every group to have its own package,
# although the same will happen if this is not set (so it defaults to ONE_PER_GROUP)
# and CPACK_DEB_COMPONENT_INSTALL is set to YES
set(CPACK_COMPONENTS_GROUPING ALL_COMPONENTS_IN_ONE)#ONE_PER_GROUP)
# without this you won't be able to pack only specified component
set(CPACK_DEB_COMPONENT_INSTALL YES)

include(CPack)
