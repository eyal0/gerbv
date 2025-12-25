#!/bin/bash
#
# Builds a package containing a gerbv binary distribution for Linux based
# systems
#
# @param $1 System name e.g. 'Fedora 43'
# @param $2 Package type: 'deb' or 'rpm'
#
# @warning Expects working directory to be set to project root


# Validate arguments
RELEASE_OS="${1}"
PACKAGE_TYPE="${2}"

if [ "${RELEASE_OS}" == "" ] || [ "${PACKAGE_TYPE}" == "" ]; then
	(>&2 echo "Usage: package-linux.sh <release-os> <package-type>")
	(>&2 echo "  release-os: System name (e.g. 'Debian 13', 'Fedora 43')")
	(>&2 echo "  package-type: 'deb' or 'rpm'")
	exit 1
fi

if [ "${PACKAGE_TYPE}" != "deb" ] && [ "${PACKAGE_TYPE}" != "rpm" ]; then
	(>&2 echo "Error: package-type must be 'deb' or 'rpm'")
	exit 1
fi


# Validate environment
CPACK=`command -v cpack`
CP=`command -v cp`
DATE=`command -v date`
GIT=`command -v git`
MKDIR=`command -v mkdir`

if [ ! -x "${CPACK}" ]; then
	(>&2 echo "\`cpack' missing - ensure CMake is installed")
	exit 1
fi

if [ ! -x "${CP}" ]; then
	(>&2 echo "\`cp' missing")
	exit 1
fi

if [ ! -x "${DATE}" ]; then
	(>&2 echo "\`date' missing")
	exit 1
fi

if [ ! -x "${GIT}" ]; then
	(>&2 echo "\`git' missing")
	exit 1
fi

if [ ! -x "${MKDIR}" ]; then
	(>&2 echo "\`mkdir' missing")
	exit 1
fi


# Gather information about current build
set -e

RELEASE_COMMIT=`"${GIT}" rev-parse HEAD`
RELEASE_COMMIT_SHORT="${RELEASE_COMMIT:0:6}"
RELEASE_DATE=`"${DATE}" --rfc-3339=date`


# Build package using CPack
echo "Building ${PACKAGE_TYPE} package with cpack..."
"${CPACK}" --preset "${PACKAGE_TYPE}-opt"

if [ $? -ne 0 ]; then
	(>&2 echo "Error: cpack failed")
	exit 1
fi


# Copy package to website directory
WEBSITE_DIRECTORY='gerbv.github.io/ci'
"${MKDIR}" -p "${WEBSITE_DIRECTORY}"

# Find the generated package file in _packages/
if [ "${PACKAGE_TYPE}" == "deb" ]; then
	PACKAGE_FILE=`ls -t _packages/gerbv_*.deb | head -1`
	PACKAGE_EXTENSION="deb"
elif [ "${PACKAGE_TYPE}" == "rpm" ]; then
	PACKAGE_FILE=`ls -t _packages/gerbv-*.rpm | head -1`
	PACKAGE_EXTENSION="rpm"
fi

if [ ! -f "${PACKAGE_FILE}" ]; then
	(>&2 echo "Error: Package file not found in _packages/")
	exit 1
fi

PACKAGE_BASENAME=`basename "${PACKAGE_FILE}"`
RELEASE_FILENAME="gerbv_${RELEASE_DATE}_${RELEASE_COMMIT_SHORT}_(${RELEASE_OS}).${PACKAGE_EXTENSION}"

echo "Copying ${PACKAGE_BASENAME} to ${WEBSITE_DIRECTORY}/${RELEASE_FILENAME}"
"${CP}" "${PACKAGE_FILE}" "${WEBSITE_DIRECTORY}/${RELEASE_FILENAME}"

# Create auxiliary files
echo "${RELEASE_COMMIT}"	> "${WEBSITE_DIRECTORY}/${RELEASE_OS}.RELEASE_COMMIT"
echo "${RELEASE_COMMIT_SHORT}"	> "${WEBSITE_DIRECTORY}/${RELEASE_OS}.RELEASE_COMMIT_SHORT"
echo "${RELEASE_DATE}"		> "${WEBSITE_DIRECTORY}/${RELEASE_OS}.RELEASE_DATE"
echo "${RELEASE_FILENAME}"	> "${WEBSITE_DIRECTORY}/${RELEASE_OS}.RELEASE_FILENAME"

echo "Package created successfully: ${WEBSITE_DIRECTORY}/${RELEASE_FILENAME}"

