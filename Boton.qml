// Botón/chip neon-grid con chaflán. activo = seleccionado.
import QtQuick
import "comun"
import "comun/Pal.js" as Pal
Item {
    id: b
    property string texto: ""
    property bool activo: false
    property bool peligro: false
    property bool fuerte: false
    property bool habilitado: true
    property real tam: 11
    signal pulsado()
    implicitWidth: Math.max(44, t.implicitWidth + 26)
    implicitHeight: 30
    opacity: habilitado ? 1 : 0.35
    readonly property color tono: peligro ? Pal.alerta : Pal.neon
    Chaflan {
        anchors.fill: parent
        tl: 7; br: 7
        relleno: b.activo || b.fuerte ? (b.fuerte && !b.activo ? Pal.oscuro : b.tono)
                 : (ma.containsMouse ? "#1A1A1A" : Pal.panel)
        borde: b.activo || b.fuerte || ma.containsMouse ? b.tono : Pal.linea
    }
    Mono {
        id: t
        anchors.centerIn: parent
        text: b.texto
        tracking: 1.5
        font.pixelSize: b.tam
        font.bold: b.activo || b.fuerte
        color: b.activo ? Pal.base : (b.fuerte ? b.tono : Pal.texto)
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: b.habilitado
        cursorShape: Qt.PointingHandCursor
        onClicked: b.pulsado()
    }
}
