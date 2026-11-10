#!/usr/bin/env bash
# Put the OnePlus Y1 43" back the way it was before the 2026-11-10 cleanup.
# Run from anywhere; needs network ADB switched back on at the TV first
# (Settings > Device Preferences > Developer options > USB debugging), then `adb connect <tv ip>`.
#
# Usage:  work/restore-all.sh [tv ip]          (your TV IP)
#         REMOVE_LAUNCHER=1 work/restore-all.sh  also uninstalls the new launcher app (com.gathin.tvhome)
set -euo pipefail
cd "$(dirname "$0")/.."
export TV_HOST="${1:?usage: $0 <tv-ip>}:5555"
export TV_ADB_BINARY="${TV_ADB_BINARY:-$(command -v adb)}"
T() { tools/venv/bin/python -I tools/tv.py "$@"; }

echo "== 1. Switch the launcher's Home-key helper off (it was not on before the cleanup)"
T 'settings put secure enabled_accessibility_services ""; settings put secure accessibility_enabled 0; echo ok'

echo "== 2. Re-enable everything that was disabled, newest batch first; Home goes back to the stock launcher"
bash tools/restore.sh work/batch3-user-choice.txt
bash tools/restore.sh work/batch2-factory.txt
bash tools/restore.sh work/batch1-demo-telemetry.txt com.google.android.tvlauncher

echo "== 3. Private DNS back to the default (it was unset before)"
T 'settings put global private_dns_mode opportunistic; settings delete global private_dns_specifier; echo ok'

if [ "${REMOVE_LAUNCHER:-}" = 1 ]; then
  echo "== 4. Uninstall the new launcher (a normal sideloaded app, not a system package)"
  T 'pm uninstall com.gathin.tvhome'
fi

echo "== Check"
T 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1; echo "disabled packages:"; pm list packages -d --user 0'
echo "Expected: Home = com.google.android.tvlauncher/.MainActivity; only com.google.android.marvin.talkback disabled"
echo "(TalkBack was already off before the cleanup). Reboot the TV once afterwards."
