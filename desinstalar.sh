#!/bin/bash
# Quita VADER · BOTONES. Tus perfiles de padctl (~/.config/padctl/mappings) se conservan.
set -e
rm -rf "$HOME/.local/share/neongrid-vader"
rm -f "$HOME/.local/bin/neongrid-vader" "$HOME/.local/share/applications/neongrid-vader.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "Desinstalado. Tus perfiles siguen en ~/.config/padctl/mappings/"
