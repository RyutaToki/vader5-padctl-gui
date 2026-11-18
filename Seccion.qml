// Cabecera de sección: «// TEXTO» + línea.
import QtQuick
import "comun"
import "comun/Pal.js" as Pal
Item {
    property string texto: ""
    implicitHeight: 18
    Mono {
        id: m
        text: "// " + parent.texto
        color: Pal.neon
        font.pixelSize: 10
        tracking: 3
        anchors.verticalCenter: parent.verticalCenter
    }
    Rectangle {
        anchors.left: m.right; anchors.leftMargin: 10; anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1; color: Pal.linea
    }
}
