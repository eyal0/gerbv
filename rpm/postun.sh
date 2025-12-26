# RPM %postun scriptlet for gerbv
# Cleans up symlinks and configurations when package is removed
# $1 = 0 on complete uninstall, $1 = 1 on upgrade

PREFIX="/opt/gerbv.github"

# Only perform cleanup on complete uninstall, not on upgrade
if [ "$1" -eq 0 ]; then
    # 1. Remove binary symlink
    if [ -L /usr/bin/gerbv ]; then
        rm -f /usr/bin/gerbv
        echo "Removed symlink: /usr/bin/gerbv"
    fi

    # 2. Remove desktop file symlink
    if [ -L /usr/share/applications/gerbv.desktop ]; then
        rm -f /usr/share/applications/gerbv.desktop
        echo "Removed symlink: /usr/share/applications/gerbv.desktop"
    fi

    # 3. Remove icon symlinks
    for size in 16x16 22x22 24x24 32x32 48x48 scalable; do
        if [ -L "/usr/share/icons/hicolor/${size}/apps/gerbv.png" ]; then
            rm -f "/usr/share/icons/hicolor/${size}/apps/gerbv.png"
        fi
        if [ -L "/usr/share/icons/hicolor/${size}/apps/gerbv.svg" ]; then
            rm -f "/usr/share/icons/hicolor/${size}/apps/gerbv.svg"
        fi
    done
    echo "Removed icon symlinks"

    # 4. Remove library configuration and run ldconfig
    if [ -f /etc/ld.so.conf.d/gerbv.conf ]; then
        rm -f /etc/ld.so.conf.d/gerbv.conf
        /sbin/ldconfig
        echo "Removed library path configuration and ran ldconfig"
    fi

    echo "Gerbv cleanup complete."
fi

# Update desktop database and icon cache on both uninstall and upgrade
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications 2>/dev/null || true
    echo "Updated desktop database"
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
    echo "Updated icon cache"
fi
