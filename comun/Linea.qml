// Icono de línea dibujado desde un trazado en caja de 24x24.
import QtQuick
import QtQuick.Shapes
Item {
    id: r
    property string d: ""
    property color color: "white"
    property real lado: 22
    property real trazo: 1.6
    property color relleno: "transparent"
    width: lado; height: lado
    Shape {
        width: 24; height: 24
        transformOrigin: Item.TopLeft
        scale: r.lado / 24
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: r.color; strokeWidth: r.trazo * 24 / r.lado; fillColor: r.relleno
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            PathSvg { path: r.d }
        }
    }
}
