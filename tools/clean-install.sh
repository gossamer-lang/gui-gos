#!/bin/sh
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "${GOS:-gos}" run "$here/clean-install.gos" "$@"
