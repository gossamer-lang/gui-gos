#!/bin/sh
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
prefix=${PREFIX:-$HOME/.local}
exe=@@EXE@@
app_id=@@APP_ID@@
install -Dm755 "$here/bin/$exe" "$prefix/bin/$exe"
mkdir -p "$prefix/share/applications"
escaped=$(printf '%s' "$prefix/bin/$exe" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\$/\\$/g; s/`/\\`/g; s/%/%%/g')
while IFS= read -r line; do
    case "$line" in Exec=*) printf 'Exec="%s"\n' "$escaped" ;; *) printf '%s\n' "$line" ;; esac
done < "$here/share/applications/$app_id.desktop" > "$prefix/share/applications/$app_id.desktop"
chmod 644 "$prefix/share/applications/$app_id.desktop"
if [ -d "$here/share/icons" ]; then cp -R "$here/share/icons" "$prefix/share/"; fi
mkdir -p "$prefix/share/doc/$exe"
cp -R "$here/share/doc/$exe/." "$prefix/share/doc/$exe/"
if command -v update-desktop-database >/dev/null 2>&1; then update-desktop-database -q "$prefix/share/applications"; fi
printf 'installed %s in %s/bin\n' "$exe" "$prefix"
