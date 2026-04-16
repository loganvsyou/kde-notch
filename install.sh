#!/usr/bin/env bash
set -e

PACKAGE_ID="com.logan.notch"
PACKAGE_DIR="$(cd "$(dirname "$0")/package" && pwd)"

echo "Installing Notch plasmoid..."

# Remove any previous installation
kpackagetool6 --remove "$PACKAGE_ID" --type Plasma/Applet 2>/dev/null || true

# Install from local package directory
kpackagetool6 --install "$PACKAGE_DIR" --type Plasma/Applet

echo ""
echo "Done! Now set up the notch:"
echo ""
echo "  1. Right-click the desktop → Add Panel → Empty Panel"
echo "     (or use an existing top panel)"
echo "  2. Right-click the new panel → Edit Panel"
echo "  3. Set Height to match notchHeight (default: 30)"
echo "  4. Set Alignment to Center, Width to Fixed"
echo "  5. Click 'Add Widgets' and search for 'Notch'"
echo "  6. Right-click the panel → Panel Options → More Options"
echo "     → set Visibility to 'Windows can cover'"
echo ""
echo "Tip: install 'Panel Colorizer' from the KDE Store to make the"
echo "     panel fully transparent so only the black notch shape shows."
