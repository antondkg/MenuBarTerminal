#!/usr/bin/env bash
set -euo pipefail

APP_NAME="MenuBarTerminal"
LAUNCH_AGENT_ID="com.antondkg.menubarterminal"
TARGET_APP="$HOME/Applications/$APP_NAME.app"
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/$LAUNCH_AGENT_ID.plist"

echo "Unloading LaunchAgent..."
if launchctl print "gui/$(id -u)/$LAUNCH_AGENT_ID" >/dev/null 2>&1; then
    launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT_PLIST" || true
fi

rm -f "$LAUNCH_AGENT_PLIST"
rm -rf "$TARGET_APP"

echo "Removed:"
echo "  $LAUNCH_AGENT_PLIST"
echo "  $TARGET_APP"
