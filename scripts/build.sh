#!/usr/bin/env bash
set -euo pipefail
PKG="${RBNX_PACKAGE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
MODE="${ROBONIX_ROBOT_DESCRIPTION_MODE:-docker}"
cd "$PKG"

if [[ "${RBNX_BUILD_CLEAN:-}" == "1" ]]; then
    rm -rf rbnx-build
fi
mkdir -p rbnx-build/runtime
rbnx codegen -p "$PKG" --out-dir "$PKG/rbnx-build/codegen"

case "$MODE" in
    native)
        set +u
        source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
        set -u
        ros2 pkg prefix robot_state_publisher >/dev/null
        ros2 pkg prefix rmw_zenoh_cpp >/dev/null
        ;;
    docker)
        docker build --network=host -t robonix/primitive-robot-description:humble -f docker/Dockerfile .
        ;;
    *)
        echo "[robot_description/build] mode must be native or docker, got '$MODE'" >&2
        exit 2
        ;;
esac

python3 -m unittest discover -s tests -v
touch rbnx-build/.rbnx-built
echo "[robot_description/build] complete ($MODE)"

