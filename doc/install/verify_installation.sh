#!/bin/bash
# Verification script for gerbv installation
# Works for both DEB and RPM packages
# Run after: sudo dpkg -i gerbv_*.deb  OR  sudo rpm -i gerbv-*.rpm

PREFIX="/opt/gerbv.github"
PASS=0
FAIL=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Gerbv Installation Verification"
echo "=========================================="
echo ""

# Helper function
check_test() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((PASS++))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((FAIL++))
    fi
}

# Test 1: Package installed
echo -e "${BLUE}[1/13]${NC} Checking package installation..."
if command -v dpkg >/dev/null 2>&1; then
    dpkg -l | grep -q gerbv
    check_test $? "Package 'gerbv' is installed (DEB)"
elif command -v rpm >/dev/null 2>&1; then
    rpm -q gerbv >/dev/null 2>&1
    check_test $? "Package 'gerbv' is installed (RPM)"
else
    echo -e "${YELLOW}⚠${NC} Cannot detect package manager (dpkg/rpm), skipping package check"
    echo -e "   ${YELLOW}→${NC} This is OK if installed manually"
fi

# Test 2: Installation directory exists
echo -e "${BLUE}[2/13]${NC} Checking installation directory..."
test -d "${PREFIX}"
check_test $? "Installation directory ${PREFIX} exists"

# Test 3: Binary exists in /opt
echo -e "${BLUE}[3/13]${NC} Checking binary in ${PREFIX}..."
test -x "${PREFIX}/bin/gerbv"
check_test $? "Binary ${PREFIX}/bin/gerbv exists and is executable"

# Test 4: Binary symlink in /usr/bin
echo -e "${BLUE}[4/13]${NC} Checking binary symlink..."
test -L /usr/bin/gerbv
check_test $? "Symlink /usr/bin/gerbv exists"

if [ -L /usr/bin/gerbv ]; then
    LINK_TARGET=$(readlink -f /usr/bin/gerbv)
    echo -e "   ${YELLOW}→${NC} Points to: ${LINK_TARGET}"
    test "${LINK_TARGET}" = "${PREFIX}/bin/gerbv"
    check_test $? "Symlink points to correct location"
else
    echo -e "${RED}   → Symlink check skipped (symlink doesn't exist)${NC}"
    ((FAIL++))
fi

# Test 5: Binary in PATH
echo -e "${BLUE}[5/13]${NC} Checking if gerbv is in PATH..."
which gerbv >/dev/null 2>&1
check_test $? "Binary 'gerbv' found in PATH"

# Test 6: Library exists
echo -e "${BLUE}[6/13]${NC} Checking library..."
test -f "${PREFIX}/lib/libgerbv.so.1.9.0"
check_test $? "Library ${PREFIX}/lib/libgerbv.so.1.9.0 exists"

# Test 7: Library configuration
echo -e "${BLUE}[7/13]${NC} Checking library path configuration..."
test -f /etc/ld.so.conf.d/gerbv.conf
check_test $? "Library config /etc/ld.so.conf.d/gerbv.conf exists"

if [ -f /etc/ld.so.conf.d/gerbv.conf ]; then
    CONF_CONTENT=$(cat /etc/ld.so.conf.d/gerbv.conf)
    echo -e "   ${YELLOW}→${NC} Contains: ${CONF_CONTENT}"
    test "${CONF_CONTENT}" = "${PREFIX}/lib"
    check_test $? "Library config contains correct path"
fi

# Test 8: Library can be found by ldconfig
echo -e "${BLUE}[8/13]${NC} Checking if library is in ldconfig cache..."
ldconfig -p | grep -q libgerbv
check_test $? "Library 'libgerbv' found in ldconfig cache"

# Test 9: Desktop file symlink
echo -e "${BLUE}[9/13]${NC} Checking desktop file..."
test -L /usr/share/applications/gerbv.desktop
check_test $? "Desktop file symlink exists"

if [ -L /usr/share/applications/gerbv.desktop ]; then
    DESKTOP_TARGET=$(readlink -f /usr/share/applications/gerbv.desktop)
    echo -e "   ${YELLOW}→${NC} Points to: ${DESKTOP_TARGET}"
fi

# Test 10: Icons
echo -e "${BLUE}[10/13]${NC} Checking icon symlinks..."
ICON_COUNT=0
for size in 16x16 22x22 24x24 32x32 48x48 scalable; do
    if [ -L "/usr/share/icons/hicolor/${size}/apps/gerbv.png" ] || \
       [ -L "/usr/share/icons/hicolor/${size}/apps/gerbv.svg" ]; then
        ((ICON_COUNT++))
    fi
done
test ${ICON_COUNT} -gt 0
check_test $? "Icon symlinks created (found ${ICON_COUNT} icons)"

# Test 11: GLib schemas
echo -e "${BLUE}[11/13]${NC} Checking GLib schemas..."
test -f "${PREFIX}/share/glib-2.0/schemas/org.geda-user.gerbv.gschema.xml"
check_test $? "GLib schema XML exists"

if [ -f "${PREFIX}/share/glib-2.0/schemas/gschemas.compiled" ]; then
    echo -e "   ${GREEN}✓${NC} GLib schemas are compiled"
    ((PASS++))
else
    echo -e "   ${YELLOW}⚠${NC} GLib schemas not compiled (may affect settings persistence)"
fi

# Test 12: Binary execution test
echo -e "${BLUE}[12/13]${NC} Testing binary execution..."
if "${PREFIX}/bin/gerbv" --version >/dev/null 2>&1; then
    VERSION_OUTPUT=$("${PREFIX}/bin/gerbv" --version 2>&1 | head -1)
    echo -e "   ${YELLOW}→${NC} Version: ${VERSION_OUTPUT}"
    check_test 0 "Binary executes successfully"
else
    check_test 1 "Binary execution failed"
fi

# Test 13: Man page
echo -e "${BLUE}[13/13]${NC} Checking man page..."
test -f "${PREFIX}/share/man/man1/gerbv.1.gz"
check_test $? "Man page exists"

# Summary
echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "${GREEN}Passed: ${PASS}${NC}"
echo -e "${RED}Failed: ${FAIL}${NC}"
echo ""

if [ ${FAIL} -eq 0 ]; then
    echo -e "${GREEN}All checks passed! ✓${NC}"
    echo ""
    echo "You can now:"
    echo "  - Run 'gerbv' from any terminal"
    echo "  - Find 'Gerbv' in your application menu"
    echo "  - Open Gerber files with 'gerbv filename.gbr'"
    echo ""
    exit 0
else
    echo -e "${RED}Some checks failed!${NC}"
    echo ""
    echo "If installation just completed, try:"
    echo "  - Run 'sudo ldconfig' to update library cache"
    echo "  - Restart your desktop environment for menu updates"
    if command -v dpkg >/dev/null 2>&1; then
        echo "  - Check /var/log/dpkg.log for installation errors (DEB)"
    elif command -v rpm >/dev/null 2>&1; then
        echo "  - Check 'journalctl -xe' or /var/log/yum.log for installation errors (RPM)"
    else
        echo "  - Check package manager logs for installation errors"
    fi
    echo ""
    exit 1
fi
