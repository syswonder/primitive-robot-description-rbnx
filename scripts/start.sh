#!/usr/bin/env bash
set -euo pipefail
PKG="${RBNX_PACKAGE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PKG"

set +u
source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
set -u
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_zenoh_cpp}"

if ROBONIX_API="$(rbnx path robonix-api 2>/dev/null)"; then
    export PYTHONPATH="$ROBONIX_API:$PKG/rbnx-build/codegen/proto_gen:$PKG:${PYTHONPATH:-}"
else
    export PYTHONPATH="$PKG/rbnx-build/codegen/proto_gen:$PKG:${PYTHONPATH:-}"
fi

exec python3 -m robot_description.main

