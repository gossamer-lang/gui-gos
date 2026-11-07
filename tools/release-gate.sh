#!/bin/sh
# One isolated native-host ledger. Other OS ledgers remain required for release.
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# The gate runs inside this project, which needs its dependencies to run at all.
sh "$here/fetch.sh"
case "$(uname -s)" in Linux | FreeBSD) session_bus=yes ;; *) session_bus=no ;; esac
if [ "$session_bus" = yes ] && [ "${GUI_GATE_PRIVATE_BUS:-0}" != 1 ]; then
    export GUI_GATE_PRIVATE_BUS=1
    exec sh "$here/../../windowing-gos/tools/private-bus.sh" -- "${GOS:-gos}" run "$here/release-gate.gos" "$@"
fi
exec "${GOS:-gos}" run "$here/release-gate.gos" "$@"
