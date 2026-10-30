#!/usr/bin/env bash
# Installs @@APP@@ in /Applications and links its command into the PATH.
#
# Usage: bash install.sh
#
# Run it through bash rather than opening it: Gatekeeper checks quarantine
# when an app launches, not when a shell runs a script, so the quarantine
# removal and ad-hoc signature below take effect. On macOS Sequoia and later
# right-click -> Open no longer lets an ad-hoc signed app through.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
app=@@APP@@
exe=@@EXE@@
source="$here/$app"
dest="/Applications/$app"

[ -d "$source" ] || { echo "error: $app not found beside install.sh" >&2; exit 1; }

echo "Installing $app..."
rm -rf "$dest"
cp -R "$source" "$dest"
xattr -dr com.apple.quarantine "$dest" 2>/dev/null || true
codesign --force --deep --sign - --timestamp=none "$dest" >/dev/null 2>&1 || true
echo "  Installed to $dest"

echo ""
echo "Linking $exe into the PATH (may prompt for sudo)..."
for dir in /usr/local/bin /opt/homebrew/bin; do
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir" 2>/dev/null || continue
    fi
    sudo ln -sf "$dest/Contents/MacOS/$exe" "$dir/$exe" 2>/dev/null || continue
    echo "  $dir/$exe"
done

echo ""
echo "Done. Launch it from /Applications or run: $exe"

case ":${PATH}:" in
    *":/usr/local/bin:"* | *":/opt/homebrew/bin:"*) ;;
    *)
        case "${SHELL##*/}" in
            zsh) profile="$HOME/.zshrc" ;;
            bash) profile="$HOME/.bash_profile" ;;
            fish) profile="$HOME/.config/fish/config.fish" ;;
            *) profile="your shell profile" ;;
        esac
        echo ""
        echo "Note: neither /usr/local/bin nor /opt/homebrew/bin is in your PATH, so"
        echo "'$exe' won't resolve in the shell. Add one of them to $profile:"
        echo ""
        echo "    export PATH=\"/usr/local/bin:\$PATH\""
        echo ""
        ;;
esac
