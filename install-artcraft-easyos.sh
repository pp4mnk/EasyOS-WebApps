#!/bin/sh
# pp4mnk ArtCraft WebApp installer for EasyOS / Puppy Linux
set -eu

APP_URL='https://app.getartcraft.com/'
LAUNCHER='/usr/local/bin/artcraft-webapp'
DESKTOP='/usr/share/applications/artcraft-webapp.desktop'
PROFILE='/root/.config/pp4mnk-artcraft-webapp'

if [ "$(id -u)" -ne 0 ]; then
  echo 'ERROR: Run this installer as root (EasyOS normally runs as root).' >&2
  exit 1
fi

if [ ! -x /usr/bin/chromium ]; then
  echo 'ERROR: /usr/bin/chromium was not found or is not executable.' >&2
  exit 1
fi

mkdir -p /usr/local/bin /usr/share/applications "$PROFILE"
cat > "$LAUNCHER" <<'LAUNCH'
#!/bin/sh
# pp4mnk ArtCraft Chromium WebApp
URL='https://app.getartcraft.com/'
CHROMIUM='/usr/bin/chromium'
PROFILE='/root/.config/pp4mnk-artcraft-webapp'

if [ ! -x "$CHROMIUM" ]; then
  echo "ERROR: Chromium not found at $CHROMIUM" >&2
  exit 1
fi
mkdir -p "$PROFILE"
# Running Chromium as root requires --no-sandbox, which reduces security.
# Prefer a non-root browser session when supported by the system.
if [ "$(id -u)" -eq 0 ]; then
  exec "$CHROMIUM" --no-sandbox --user-data-dir="$PROFILE" --no-first-run --no-default-browser-check --app="$URL" "$@"
else
  exec "$CHROMIUM" --user-data-dir="${XDG_CONFIG_HOME:-$HOME/.config}/pp4mnk-artcraft-webapp" --no-first-run --no-default-browser-check --app="$URL" "$@"
fi
LAUNCH
chmod 755 "$LAUNCHER"

cat > "$DESKTOP" <<'DESKTOPFILE'
[Desktop Entry]
Version=1.0
Type=Application
Name=ArtCraft WebApp
Comment=ArtCraft AI Creative Studio in Chromium
Exec=/usr/local/bin/artcraft-webapp
Icon=applications-graphics
Terminal=false
Categories=Graphics;
StartupNotify=true
DESKTOPFILE
chmod 644 "$DESKTOP"

if command -v fixmenus >/dev/null 2>&1; then
  fixmenus || echo 'WARNING: fixmenus failed; menu may require manual refresh.' >&2
fi
if command -v jwm >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  jwm -restart || echo 'WARNING: JWM restart failed; log out/in to refresh menu.' >&2
fi
printf '\nArtCraft WebApp installed.\nMenu: Graphics -> ArtCraft WebApp\nLaunch command: artcraft-webapp\n'
printf 'NOTE: --no-sandbox is used when running as root; this reduces browser security.\n'
