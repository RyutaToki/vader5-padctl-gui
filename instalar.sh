#!/bin/bash
# Instala VADER · BOTONES para el usuario actual (sin sudo).
# Requiere: padctl y PySide6 (Arch: sudo pacman -S pyside6).
set -e
command -v padctl >/dev/null || echo "Aviso: padctl no está instalado; la app no podrá aplicar perfiles."
python3 -c "import PySide6" 2>/dev/null || { echo "Falta PySide6 (Arch: sudo pacman -S pyside6)"; exit 1; }
ORIGEN="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.local/share/neongrid-vader"
mkdir -p "$DEST/comun" "$HOME/.local/bin" "$HOME/.local/share/applications"
install -m 755 "$ORIGEN/vader-botones" "$DEST/"
install -m 644 "$ORIGEN"/*.qml "$DEST/"
install -m 644 "$ORIGEN"/comun/* "$DEST/comun/"
ln -sf "$DEST/vader-botones" "$HOME/.local/bin/neongrid-vader"
install -m 644 "$ORIGEN/neongrid-vader.desktop" "$HOME/.local/share/applications/"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "Instalado: menú → Vader · Botones"
