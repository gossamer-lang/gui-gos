#!/bin/sh
# Packages the fresh native build output of an example application.
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "${GOS:-gos}" run "$here/package.gos" "$@"
