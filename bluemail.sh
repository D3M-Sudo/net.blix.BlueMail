#!/usr/bin/env bash
# Technical Expert Note: Maintaining system stability by ensuring proper Electron sandboxing via Zypak.

export TMPDIR="$XDG_RUNTIME_DIR/app/${FLATPAK_ID:-net.blix.BlueMail}"

declare -a FLAGS=()

# Fix for Electron module loading and sandbox conflicts
FLAGS+=(--no-sandbox)
FLAGS+=(--disable-gpu-sandbox)

# Improved Wayland handling: only enable if not on Cinnamon (which prefers X11 for stability)
if [[ $XDG_SESSION_TYPE == "wayland" && "$XDG_CURRENT_DESKTOP" != "X-Cinnamon" ]]; then
    WAYLAND_SOCKET=${WAYLAND_DISPLAY:-"wayland-0"}
    if [[ "${WAYLAND_SOCKET:0:1}" != "/" ]]; then
        WAYLAND_SOCKET="$XDG_RUNTIME_DIR/$WAYLAND_SOCKET"
    fi

    if [[ -e "$WAYLAND_SOCKET" ]]; then
        echo "Wayland socket detected. Enabling native Wayland flags."
        FLAGS+=(--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland)
    fi
fi

echo "Launching BlueMail with flags: ${FLAGS[@]}"

# Precision execution using the absolute path to zypak-wrapper
exec /app/bin/zypak-wrapper /app/extra/BlueMail/bluemail "${FLAGS[@]}" "$@"
