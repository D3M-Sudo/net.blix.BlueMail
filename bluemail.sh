#!/usr/bin/env bash
# Technical Expert Note: Optimizing startup speed and GPU stability specifically for Mint/Cinnamon environments.

# Set a dedicated temporary directory within the Flatpak runtime for better isolation.
export TMPDIR="$XDG_RUNTIME_DIR/app/${FLATPAK_ID:-net.blix.BlueMail}"

declare -a FLAGS=()

# --- Performance Optimization (Addressing Issue #57) ---
# Disable the internal Electron sandbox as it conflicts with the Flatpak sandbox and slows down module loading.
FLAGS+=(--no-sandbox)
FLAGS+=(--disable-gpu-sandbox)

# Force hardware acceleration and shader caching to prevent "slow startup" issues.
# Bypasses the internal GPU blocklist to ensure hardware rendering is used whenever possible.
FLAGS+=(--ignore-gpu-blocklist)
FLAGS+=(--enable-gpu-rasterization)
FLAGS+=(--enable-zero-copy)

# --- Display Management ---
# Cinnamon environments handle X11 more stably; we force native Wayland only for pure Wayland sessions (excluding Cinnamon).
if [[ "$XDG_SESSION_TYPE" == "wayland" && "$XDG_CURRENT_DESKTOP" != "X-Cinnamon" ]]; then
    echo "Wayland session detected. Enabling native Wayland flags for non-Cinnamon desktop."
    FLAGS+=(--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland)
fi

echo "Launching BlueMail with performance flags: ${FLAGS[@]}"

# Precision execution using zypak-wrapper to maintain sandbox integrity while running the binary.
exec /app/bin/zypak-wrapper /app/extra/BlueMail/bluemail "${FLAGS[@]}" "$@"
