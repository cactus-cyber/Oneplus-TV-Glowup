#!/usr/bin/env bash
# Rebuild the launcher from launcher/app/src/main/res/values/config.xml and install it on the
# OnePlus Y1 43" as Home, with the Home-key helper (power-on lands on Home).
#
# Usage:  work/install-launcher.sh [tv ip]      (your TV IP)
#
# Why step 1: on this TV (Android 11), replacing the launcher while its Home-key helper is bound
# crashed Android's system process once ("Death link does not exist" in accessibility, 2026-11-10);
# the TV restarted its UI by itself and recovered. Switching the helper off first avoids that.
set -euo pipefail
cd "$(dirname "$0")/.."
export TV_HOST="${1:?usage: $0 <tv-ip>}:5555"
export TV_ADB_BINARY="${TV_ADB_BINARY:-$(command -v adb)}"
T() { tools/venv/bin/python -I tools/tv.py "$@"; }

echo "== 1. Unbind the Home-key helper before the APK is replaced"
T 'settings put secure enabled_accessibility_services ""; settings put secure accessibility_enabled 0; sleep 2; echo ok'

echo "== 2. Build, install, make it Home, and bind the helper again"
HOME_KEY_SERVICE=1 bash launcher/build-and-install.sh

echo "== 3. Check"
T 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1; settings get secure enabled_accessibility_services'
echo "Expected: com.gathin.tvhome/.MainActivity and com.gathin.tvhome/.HomeKeyService"
