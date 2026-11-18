// Forma con esquinas en diagonal. tl/tr/br/bl = tamaño de cada chaflán en px.
// diagonales=false deja la diagonal sin trazo, como en la referencia.
import QtQuick
import QtQuick.Shapes
Shape {
    id: s
    property real tl: 0; property real tr: 0; property real br: 0; property real bl: 0
    property color relleno: "transparent"
    property color borde: "transparent"
    property real grosor: 1
    property bool diagonales: true
    preferredRendererType: Shape.CurveRenderer
    readonly property real o: grosor / 2
    readonly property real w0: width - o
    readonly property real h0: height - o
    function contorno() {
        return "M" + (o+tl) + " " + o + "L" + (w0-tr) + " " + o + "L" + w0 + " " + (o+tr) + "L" + w0 + " " + (h0-br)
             + "L" + (w0-br) + " " + h0 + "L" + (o+bl) + " " + h0 + "L" + o + " " + (h0-bl) + "L" + o + " " + (o+tl) + "Z";
    }
    function tramos() {
        return "M" + (o+tl) + " " + o + "L" + (w0-tr) + " " + o
             + "M" + w0 + " " + (o+tr) + "L" + w0 + " " + (h0-br)
             + "M" + (w0-br) + " " + h0 + "L" + (o+bl) + " " + h0
             + "M" + o + " " + (h0-bl) + "L" + o + " " + (o+tl);
    }
    ShapePath { strokeWidth: 0; strokeColor: "transparent"; fillColor: s.relleno; PathSvg { path: s.contorno() } }
    ShapePath {
        strokeWidth: s.grosor; strokeColor: s.borde; fillColor: "transparent"
        capStyle: ShapePath.SquareCap
        PathSvg { path: s.diagonales ? s.contorno() : s.tramos() }
    }
}
