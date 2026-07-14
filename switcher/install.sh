#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${VOHIVE_CONFIG:-/opt/vohive/config/config.yaml}"
SERVICE="${VOHIVE_SERVICE:-vohive.service}"

[[ $EUID -eq 0 ]] || { echo 'Run with sudo.' >&2; exit 1; }
[[ -f "$CONFIG" ]] || { echo "Missing VoHive config: $CONFIG" >&2; exit 1; }
command -v systemctl >/dev/null || { echo 'systemd is required.' >&2; exit 1; }
systemctl cat "$SERVICE" >/dev/null || { echo "Missing service: $SERVICE" >&2; exit 1; }

if ! python3 -c 'import serial' >/dev/null 2>&1; then
  apt-get update
  apt-get install -y python3-serial
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="${CONFIG}.before-usb-switcher-${STAMP}"
cp -a "$CONFIG" "$BACKUP"

if ! grep -qE '^[[:space:]]*port:[[:space:]]*7576[[:space:]]*$' "$CONFIG"; then
  sed -i -E 's/^([[:space:]]*port:[[:space:]]*)7575[[:space:]]*$/\17576/' "$CONFIG"
fi

install -o root -g root -m 0755 "$ROOT_DIR/switcher/bin/vohive-usb-mode" /usr/local/sbin/vohive-usb-mode
install -o root -g root -m 0755 "$ROOT_DIR/switcher/bin/vohive-web-gateway" /usr/local/sbin/vohive-web-gateway
install -o root -g root -m 0644 "$ROOT_DIR/switcher/systemd/vohive-web-gateway.service" /etc/systemd/system/vohive-web-gateway.service

systemctl daemon-reload
systemctl restart "$SERVICE"
systemctl enable --now vohive-web-gateway.service
systemctl is-active --quiet "$SERVICE"
systemctl is-active --quiet vohive-web-gateway.service
echo "Installed. Config backup: $BACKUP"
