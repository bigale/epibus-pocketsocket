#!/bin/bash

# Quick test for WSL2 window management capabilities

echo "🔍 Testing WSL2 Window Management Tools"
echo "======================================"

# Test X11 connection
echo -n "X11 Connection: "
if [ -n "$DISPLAY" ] && xdpyinfo >/dev/null 2>&1; then
    echo "✅ Working ($DISPLAY)"
else
    echo "❌ Failed"
fi

# Test wmctrl
echo -n "wmctrl: "
if command -v wmctrl >/dev/null 2>&1; then
    echo "✅ Available"
    echo "  Current windows:"
    wmctrl -l | head -3 | sed 's/^/    /'
else
    echo "❌ Not found"
fi

# Test xdotool
echo -n "xdotool: "
if command -v xdotool >/dev/null 2>&1; then
    echo "✅ Available"
else
    echo "❌ Not found"
fi

# Test browser
echo -n "Browser: "
if command -v google-chrome >/dev/null 2>&1; then
    echo "✅ Google Chrome"
elif command -v chromium-browser >/dev/null 2>&1; then
    echo "✅ Chromium"
elif command -v firefox >/dev/null 2>&1; then
    echo "✅ Firefox"
elif command -v cmd.exe >/dev/null 2>&1; then
    echo "✅ Windows integration (cmd.exe)"
else
    echo "❌ No browser found"
fi

# Test screen info
echo -n "Screen info: "
if command -v xdpyinfo >/dev/null 2>&1; then
    screen_info=$(xdpyinfo | grep dimensions | awk '{print $2}')
    echo "✅ $screen_info"
else
    echo "❌ Cannot detect"
fi

# Test sudo status
echo -n "Sudo capability: "
if sudo -n true 2>/dev/null; then
    echo "✅ Available"
else
    echo "❌ Restricted (WSL2 'no new privileges' flag)"
fi

echo ""
echo "🎯 Recommendations:"
if ! command -v wmctrl >/dev/null 2>&1; then
    echo "  • Install wmctrl for window management"
fi
if ! command -v xdotool >/dev/null 2>&1; then
    echo "  • Install xdotool for advanced window control"
fi
if ! command -v google-chrome >/dev/null 2>&1 && ! command -v chromium-browser >/dev/null 2>&1; then
    echo "  • Install browser or use Windows browser integration"
fi

echo ""
echo "📋 Alternative installation (without sudo):"
echo "  • Use Windows Package Manager: winget install"
echo "  • Download .deb packages and install manually"
echo "  • Use snap packages if available"
echo "  • Use Windows browsers via WSL integration"
