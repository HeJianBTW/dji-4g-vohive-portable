#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG="${VOHIVE_CONFIG:-/opt/vohive/config/config.yaml}"
SERVICE="${VOHIVE_SERVICE:-vohive.service}"
[[ $EUID -eq 0 ]] || { echo 'Run with sudo.' >&2; exit 1; }
BACKUP="$(ls -t "${CONFIG}".before-usb-switcher-* 2>/dev/null | head -n 1 || true)"
[[ -n "$BACKUP" ]] || { echo 'No backup found; refusing to modify config.' >&2; exit 1; }

systemctl disable --now vohive-web-gateway.service 2>/dev/null || true
rm -f /etc/systemd/system/vohive-web-gateway.service /usr/local/sbin/vohive-web-gateway /usr/local/sbin/vohive-usb-mode
cp -a "$BACKUP" "$CONFIG"
systemctl daemon-reload
systemctl restart "$SERVICE"
echo "Removed switcher; restored $BACKUP"
