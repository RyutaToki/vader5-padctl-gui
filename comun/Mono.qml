// Etiqueta en mono con espaciado amplio.
import QtQuick
import "Pal.js" as Pal
Text {
    property real tracking: 2
    font.family: Pal.mono; font.pixelSize: 11; font.letterSpacing: tracking
    color: Pal.texto2
}
