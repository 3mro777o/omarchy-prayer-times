#!/usr/bin/env bash
# Install the prayer-times bar widget and adhan service on Omarchy.
set -euo pipefail
cd "$(dirname "$0")"

PLUGIN_ID=blacknova.prayer-times
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
SOUNDS="$HOME/.local/share/prayer-times/sounds"

install -Dm755 bin/prayer-times "$HOME/.local/bin/prayer-times"
install -Dm644 systemd/prayer-times.service "$HOME/.config/systemd/user/prayer-times.service"
mkdir -p "$PLUGIN_DIR" "$SOUNDS"
cp plugin/* "$PLUGIN_DIR/"

# Adhan (Mishary Alafasy) and alert sounds, as served by mawaqit.net
for n in adhan-afassy adhan-afassy-fajr bip; do
  [[ -f "$SOUNDS/$n.mp3" ]] || curl -fsSL -o "$SOUNDS/$n.mp3" "https://mawaqit.net/static/mp3/$n.mp3"
done

command -v mpv >/dev/null || omarchy pkg add mpv

"$HOME/.local/bin/prayer-times" fetch
systemctl --user daemon-reload
systemctl --user enable --now prayer-times.service

omarchy-shell shell rescanPlugins >/dev/null || true
omarchy plugin enable "$PLUGIN_ID" || true
echo "Done. Next prayer: $("$HOME/.local/bin/prayer-times" next)"
