# DJI 4G + VoHive Portable

Private deployment backup for a repurposed DJI Gen1 4G module.

- `original/` contains the retained upstream README and offline VoHive assets.
- `switcher/` adds QMI/ECM switching buttons to the existing VoHive web page.

## Deploy

First deploy VoHive with `original/README.upstream.md`. Then on the Linux host:

```bash
git clone <your-private-repository-url>
cd dji-4g-vohive-portable
sudo ./switcher/install.sh
```

The existing VoHive address stays on port `7575`. The page gains two buttons:

- **External network adapter**: pause VoHive and switch the module to ECM.
- **Restore VoHive**: switch the module back to QMI and automatically restart VoHive.

Do not commit `/opt/vohive/config/config.yaml`, databases, logs, SIM data, server addresses, or push-platform credentials.

This package is intended for Linux + systemd + native VoHive. Do not put the USB mode switcher in Docker: it needs USB serial/QMI devices and systemd service control on the host.
