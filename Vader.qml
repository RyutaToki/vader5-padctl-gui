// VADER · BOTONES — ventana principal.
import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "comun"
import "comun/Pal.js" as Pal

Window {
    id: w
    width: 1180; height: 760
    minimumWidth: 1000; minimumHeight: 680
    visible: true
    color: Pal.base
    title: "VADER · BOTONES"

    // ---------- estado ----------
    property var cat: backend.catalogo()
    property var lista: backend.perfiles()
    property var est: backend.estado()
    property var perfil: ({ nombre: "", botones: {}, gyro: { modo: "off", activar: "", sensibilidad: 2.0 } })
    property string anterior: ""      // nombre con el que se cargó (para renombrar)
    property bool sucio: false
    property string sel: "M1"
    property bool verNormales: false
    property string avisoTexto: ""
    property bool avisoError: false
    property string confirmar: ""     // "", "aplicar", "borrar", "original", "cambiar:<perfil>"
    property string pasoPrueba: ""
    property string capturaRuta: ""
    onCapturaRutaChanged: if (capturaRuta) contentItem.grabToImage(function (r) { r.saveToFile(w.capturaRuta); Qt.quit() })

    property string mantTipoElegido: ""
    onSelChanged: mantTipoElegido = ""
    readonly property string mantTipo: mantTipoElegido || (b.mantener ? (b.mantener.indexOf("KEY_") === 0 ? "tecla" : b.mantener.indexOf("mouse_") === 0 ? "raton" : "mando") : "mando")
    readonly property var b: perfil.botones[sel] || ({ tipo: "original", valor: "", modo: "normal", turbo: 12, mantener: "", mantenerMs: 300 })

    readonly property var info: ({
        "M1": ["PALETA M1", "trasera · arriba derecha"],
        "M2": ["PALETA M2", "trasera · arriba izquierda"],
        "M3": ["PALETA M3", "trasera · abajo derecha"],
        "M4": ["PALETA M4", "trasera · abajo izquierda"],
        "C":  ["BOTÓN C", "frontal · a la derecha de Y"],
        "Z":  ["BOTÓN Z", "frontal · a la izquierda de A"],
        "LM": ["MINI GATILLO LM", "superior · junto a LB"],
        "RM": ["MINI GATILLO RM", "superior · junto a RB"],
        "O":  ["BOTÓN O", "botón extra del mando"],
        "A": ["A", "frontal"], "B": ["B", "frontal"], "X": ["X", "frontal"], "Y": ["Y", "frontal"],
        "LB": ["LB", "bumper izquierdo"], "RB": ["RB", "bumper derecho"],
        "LS": ["L3", "clic del stick izquierdo"], "RS": ["R3", "clic del stick derecho"],
        "Start": ["MENÚ", "botón Start"], "Select": ["VISTA", "botón Select"], "Home": ["HOME", "botón central"],
        "DPadUp": ["CRUCETA ↑", "cruceta"], "DPadDown": ["CRUCETA ↓", "cruceta"],
        "DPadLeft": ["CRUCETA ←", "cruceta"], "DPadRight": ["CRUCETA →", "cruceta"]
    })
    readonly property var fabrica: ({
        "M1": "paleta P1 del Elite", "M2": "paleta P3 del Elite", "M3": "paleta P2 del Elite",
        "M4": "paleta P4 del Elite", "C": "botón extra 9", "Z": "botón extra 10",
        "LM": "botón extra 11", "RM": "botón extra 12", "O": "botón extra 13"
    })

    function nombreDe(v) {
        if (!v) return "—"
        if (v === "disabled") return "DESACTIVADO"
        if (v.indexOf("KEY_") === 0) return "TECLA " + v.substring(4)
        var r = { mouse_left: "CLIC IZQ.", mouse_right: "CLIC DCHO.", mouse_middle: "CLIC RUEDA",
                  mouse_side: "RATÓN LATERAL", mouse_extra: "RATÓN EXTRA",
                  mouse_forward: "RATÓN ADELANTE", mouse_back: "RATÓN ATRÁS" }
        if (r[v]) return r[v]
        return info[v] ? info[v][0] : (v === "LT" ? "LT" : v === "RT" ? "RT" : v)
    }
    function resumen(boton) {
        var x = perfil.botones[boton]
        if (!x || x.tipo === "original") return "de fábrica"
        if (x.tipo === "desactivado") return "DESACTIVADO"
        if (!x.valor) return "sin elegir"
        var s = nombreDe(x.valor)
        if (x.modo === "turbo") s += " · TURBO " + x.turbo + "/s"
        if (x.modo === "mantener" && x.mantener) s += " · MANT. " + nombreDe(x.mantener)
        return s
    }
    function clonar(o) { return JSON.parse(JSON.stringify(o)) }
    function cambiar(cambios) {
        var p = clonar(perfil)
        var x = p.botones[sel] || { tipo: "original", valor: "", modo: "normal", turbo: 12, mantener: "", mantenerMs: 300 }
        for (var k in cambios) x[k] = cambios[k]
        if (x.tipo === "original") delete p.botones[sel]
        else p.botones[sel] = x
        perfil = p; sucio = true
    }
    function cambiarGyro(cambios) {
        var p = clonar(perfil)
        for (var k in cambios) p.gyro[k] = cambios[k]
        perfil = p; sucio = true
    }
    function cargar(nombre) {
        var p = backend.cargar(nombre)
        perfil = p; anterior = nombre; sucio = false
        avisar(p.propio ? "" : "Este perfil no se creó con esta app: se muestran solo los ajustes que entiende", !p.propio && false)
    }
    function nuevo(base) {
        var p = base ? clonar(perfil) : { botones: {}, gyro: { modo: "off", activar: "", sensibilidad: 2.0 } }
        var n = 1, nom
        do { nom = (base ? slug(perfil.nombre) + "-copia" : "perfil") + (n > 1 ? "-" + n : (base ? "" : "-1")); n++ }
        while (lista.indexOf(nom) >= 0)
        p.nombre = nom
        perfil = p; anterior = ""; sucio = true
        nombreCampo.text = nom
    }
    function slug(t) { return t.toLowerCase().replace(/[^a-z0-9-]+/g, "-").replace(/^-+|-+$/g, "").substring(0, 40) || "perfil" }
    function guardar() {
        var p = clonar(perfil); p.nombre = slug(nombreCampo.text); p.anterior = anterior
        var n = backend.guardar(p)
        if (n) { lista = backend.perfiles(); perfil.nombre = n; anterior = n; sucio = false; nombreCampo.text = n }
        return n
    }
    function avisar(t, e) { avisoTexto = t; avisoError = !!e; if (t) avisoTimer.restart() }

    Connections {
        target: backend
        function onAviso(t, e) { w.avisar(t, e) }
        function onEstadoCambiado() { w.est = backend.estado() }
        function onPerfilesCambiados() { w.lista = backend.perfiles() }
    }
    Timer { id: avisoTimer; interval: 6000; onTriggered: w.avisoTexto = "" }

    Component.onCompleted: {
        var ini = est.perfil && lista.indexOf(est.perfil) >= 0 ? est.perfil : (lista.length ? lista[0] : "")
        if (ini) { cargar(ini); nombreCampo.text = ini } else nuevo(false)
    }

    // Solo para pruebas automáticas (--pasos).
    onPasoPruebaChanged: {
        if (!pasoPrueba) return
        var p = JSON.parse(pasoPrueba)
        if (p.sel) sel = p.sel
        if (p.cambiar) cambiar(p.cambiar)
        if (p.gyro) cambiarGyro(p.gyro)
        if (p.normales !== undefined) verNormales = p.normales
        if (p.confirmar !== undefined) confirmar = p.confirmar
        if (p.guardar) guardar()
        if (p.nombre) nombreCampo.text = p.nombre
    }

    // ---------- cabecera ----------
    Rectangle {
        id: cabecera
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 58; color: Pal.panel
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Pal.linea }
        Rectangle { width: 4; height: parent.height; color: Pal.neon }
        Row {
            anchors.verticalCenter: parent.verticalCenter; x: 22; spacing: 14
            Text { text: "VADER 5 PRO"; color: Pal.texto; font.family: Pal.titulo; font.pixelSize: 20; font.bold: true; font.letterSpacing: 3 }
            Mono { text: "// BOTONES"; color: Pal.neon; font.pixelSize: 13; tracking: 3; anchors.baseline: parent.children[0].baseline }
            Mono { visible: w.sucio; text: "● CAMBIOS SIN GUARDAR"; color: Pal.alerta; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
            Chaflan {
                visible: modoPrueba; width: 130; height: 22; tl: 5; br: 5; relleno: Pal.oscuro; borde: Pal.alerta
                anchors.verticalCenter: parent.verticalCenter
                Mono { anchors.centerIn: parent; text: "MODO PRUEBA"; color: Pal.alerta; font.pixelSize: 10 }
            }
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter; anchors.right: parent.right; anchors.rightMargin: 22; spacing: 10
            Rectangle {
                width: 8; height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter
                color: est.conectado ? Pal.neon : Pal.anclado
                SequentialAnimation on opacity { running: est.conectado; loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 900 } NumberAnimation { to: 1; duration: 900 } }
            }
            Mono { text: est.texto; color: est.conectado ? Pal.texto : Pal.apagado; font.pixelSize: 11 }
            Mono { text: "·  ACTIVO: " + (est.perfil ? est.perfil.toUpperCase() : "DE FÁBRICA"); color: Pal.apagado; font.pixelSize: 11 }
        }
    }

    // ---------- barra de perfiles ----------
    Item {
        id: barraPerfil
        anchors { left: parent.left; right: parent.right; top: cabecera.bottom; margins: 22 }
        height: 34
        Row {
            spacing: 8; anchors.verticalCenter: parent.verticalCenter
            Mono { text: "PERFIL"; color: Pal.apagado; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
            ComboBox {
                id: combo
                width: 190; height: 30
                model: w.lista
                currentIndex: w.lista.indexOf(w.anterior)
                displayText: w.anterior ? w.anterior.toUpperCase() : "(SIN GUARDAR)"
                onActivated: (i) => {
                    var n = w.lista[i]
                    if (w.sucio) { w.confirmar = "cambiar:" + n; currentIndex = w.lista.indexOf(w.anterior) }
                    else { w.cargar(n); nombreCampo.text = n }
                }
                font.family: Pal.mono; font.pixelSize: 11
                background: Chaflan { tl: 7; br: 7; relleno: Pal.panel; borde: combo.hovered ? Pal.neon : Pal.linea }
                contentItem: Mono { leftPadding: 12; text: combo.displayText; color: Pal.texto; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                indicator: Mono { x: combo.width - 22; anchors.verticalCenter: parent.verticalCenter; text: "▾"; color: Pal.neon }
                delegate: ItemDelegate {
                    width: combo.width; height: 28
                    contentItem: Mono { text: modelData.toUpperCase(); color: modelData === w.est.perfil ? Pal.neon : Pal.texto; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: hovered ? Pal.oscuro : Pal.panel }
                }
                popup.background: Rectangle { color: Pal.panel; border.color: Pal.neon }
            }
            Boton { texto: "NUEVO"; onPulsado: w.nuevo(false) }
            Boton { texto: "DUPLICAR"; onPulsado: w.nuevo(true) }
            Boton { texto: "BORRAR"; peligro: true; habilitado: w.anterior !== ""; onPulsado: w.confirmar = "borrar" }
            Item { width: 12; height: 1 }
            Mono { text: "NOMBRE"; color: Pal.apagado; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
            Item {
                width: 170; height: 30
                Chaflan { anchors.fill: parent; tl: 7; br: 7; relleno: Pal.panel; borde: nombreCampo.activeFocus ? Pal.neon : Pal.linea }
                TextInput {
                    id: nombreCampo
                    anchors.fill: parent; leftPadding: 12; verticalAlignment: Text.AlignVCenter
                    color: Pal.texto; font.family: Pal.mono; font.pixelSize: 11; selectByMouse: true
                    maximumLength: 40; clip: true
                    onTextEdited: w.sucio = true
                }
            }
        }
        Row {
            spacing: 8; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            Boton { texto: "DE FÁBRICA"; onPulsado: w.confirmar = "original" }
            Boton { texto: "GUARDAR"; habilitado: w.sucio; onPulsado: w.guardar() }
            Boton { texto: "APLICAR AL MANDO"; fuerte: true; onPulsado: w.confirmar = "aplicar" }
        }
    }

    // ---------- columna izquierda: botones ----------
    Flickable {
        id: izq
        anchors { left: parent.left; top: barraPerfil.bottom; bottom: pie.top; margins: 22 }
        width: 470
        contentHeight: colIzq.height; clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        Column {
            id: colIzq
            width: izq.width - 10; spacing: 10

            Seccion { texto: "SUPERIOR · MINI GATILLOS"; width: parent.width }
            Grid { columns: 2; spacing: 8; Repeater { model: ["LM", "RM"]; Ficha { boton: modelData } } }
            Seccion { texto: "TRASERA · PALETAS"; width: parent.width }
            Grid { columns: 2; spacing: 8; Repeater { model: ["M2", "M1", "M4", "M3"]; Ficha { boton: modelData } } }
            Seccion { texto: "FRONTAL · EXTRA"; width: parent.width }
            Grid { columns: 2; spacing: 8; Repeater { model: ["Z", "C", "O"]; Ficha { boton: modelData } } }

            Item { width: 1; height: 4 }
            Boton {
                texto: (w.verNormales ? "▾ " : "▸ ") + "BOTONES NORMALES (A, B, X, Y, BUMPERS…)"
                width: parent.width; onPulsado: w.verNormales = !w.verNormales
            }
            Grid {
                visible: w.verNormales; columns: 2; spacing: 8
                Repeater { model: w.cat.normales; Ficha { boton: modelData } }
            }
        }
    }

    component Ficha: Item {
        id: f
        property string boton
        width: 226; height: 58
        readonly property bool elegido: w.sel === boton
        readonly property bool cambiado: !!w.perfil.botones[boton]
        Chaflan {
            anchors.fill: parent; tl: 10; br: 10
            relleno: f.elegido ? Pal.oscuro : Pal.panel
            borde: f.elegido ? Pal.neon : (fm.containsMouse ? Pal.medio : Pal.linea)
            grosor: f.elegido ? 1.5 : 1
        }
        Rectangle { visible: f.cambiado; x: 0; y: 14; width: 3; height: parent.height - 28; color: Pal.neon }
        Column {
            x: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 4; width: parent.width - 24
            Text { text: w.info[f.boton] ? w.info[f.boton][0] : f.boton; color: Pal.texto; font.family: Pal.titulo; font.pixelSize: 13; font.bold: true; font.letterSpacing: 1.5 }
            Mono { text: w.resumen(f.boton); color: f.cambiado ? Pal.neon : Pal.apagado; font.pixelSize: 10; tracking: 1; elide: Text.ElideRight; width: parent.width }
        }
        MouseArea { id: fm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: w.sel = f.boton }
    }

    // ---------- columna derecha: editor ----------
    Flickable {
        id: der
        anchors { left: izq.right; right: parent.right; top: barraPerfil.bottom; bottom: pie.top; margins: 22 }
        contentHeight: colDer.height; clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        Column {
            id: colDer
            width: der.width - 10; spacing: 12

            Row {
                spacing: 14
                Text { text: w.info[w.sel] ? w.info[w.sel][0] : w.sel; color: Pal.texto; font.family: Pal.titulo; font.pixelSize: 24; font.bold: true; font.letterSpacing: 2 }
                Mono { text: w.info[w.sel] ? w.info[w.sel][1].toUpperCase() : ""; color: Pal.apagado; font.pixelSize: 10; anchors.bottom: parent.children[0].bottom; anchors.bottomMargin: 4 }
            }

            Seccion { texto: "QUÉ HACE AL PULSARLO"; width: parent.width }
            Flow {
                width: parent.width; spacing: 8
                Repeater {
                    model: [["original", "DE FÁBRICA"], ["mando", "BOTÓN DEL MANDO"], ["tecla", "TECLA"], ["raton", "RATÓN"], ["desactivado", "DESACTIVAR"]]
                    Boton {
                        texto: modelData[1]; activo: w.b.tipo === modelData[0]
                        onPulsado: w.cambiar({ tipo: modelData[0], valor: modelData[0] === w.b.tipo ? w.b.valor : "",
                                               modo: (modelData[0] === "raton" && w.b.modo === "turbo") ? "normal" : w.b.modo })
                    }
                }
            }
            Mono {
                visible: w.b.tipo === "original"
                width: parent.width; wrapMode: Text.Wrap; color: Pal.apagado; font.pixelSize: 11; tracking: 0.5
                text: w.fabrica[w.sel] ? "Funciona como viene: el PC lo ve como " + w.fabrica[w.sel] + ". Steam y algunos juegos lo pueden usar directamente."
                                       : "Funciona como viene de fábrica."
            }
            Mono {
                visible: w.b.tipo === "desactivado"
                width: parent.width; wrapMode: Text.Wrap; color: Pal.apagado; font.pixelSize: 11; tracking: 0.5
                text: "Este botón no hará nada (útil si lo pulsas sin querer)."
            }

            // Selector de destino
            Column {
                visible: w.b.tipo === "mando" || w.b.tipo === "tecla" || w.b.tipo === "raton"
                width: parent.width; spacing: 8
                Mono { text: w.b.tipo === "tecla" ? "ELIGE LA TECLA" : w.b.tipo === "raton" ? "ELIGE EL BOTÓN DEL RATÓN" : "ELIGE EL BOTÓN"; color: Pal.texto2; font.pixelSize: 10 }
                Flow {
                    width: parent.width; spacing: 6
                    Repeater {
                        model: w.b.tipo === "tecla" ? w.cat.teclas : w.b.tipo === "raton" ? w.cat.raton : w.cat.mando
                        Boton {
                            texto: w.b.tipo === "tecla" ? modelData.substring(4) : w.nombreDe(modelData)
                            tam: 10; implicitHeight: 26
                            activo: w.b.valor === modelData
                            onPulsado: w.cambiar({ valor: modelData })
                        }
                    }
                }
            }

            // Modo
            Column {
                visible: (w.b.tipo === "mando" || w.b.tipo === "tecla" || w.b.tipo === "raton") && w.b.valor !== ""
                width: parent.width; spacing: 10
                Seccion { texto: "MODO"; width: parent.width }
                Flow {
                    width: parent.width; spacing: 8
                    Boton { texto: "NORMAL"; activo: w.b.modo === "normal"; onPulsado: w.cambiar({ modo: "normal" }) }
                    Boton { texto: "TURBO"; activo: w.b.modo === "turbo"; habilitado: w.b.tipo !== "raton"; onPulsado: w.cambiar({ modo: "turbo" }) }
                    Boton { texto: "PULSAR / MANTENER"; activo: w.b.modo === "mantener"; onPulsado: w.cambiar({ modo: "mantener" }) }
                }
                Mono {
                    width: parent.width; wrapMode: Text.Wrap; color: Pal.apagado; font.pixelSize: 11; tracking: 0.5
                    text: w.b.modo === "turbo" ? "Mientras lo mantienes pulsado, repite " + w.nombreDe(w.b.valor) + " " + w.b.turbo + " veces por segundo."
                        : w.b.modo === "mantener" ? "Toque corto: " + w.nombreDe(w.b.valor) + ". Mantenido: otra acción."
                        : "Hace " + w.nombreDe(w.b.valor) + " mientras lo pulsas."
                }
                Deslizador {
                    visible: w.b.modo === "turbo"
                    etiqueta: "VECES POR SEGUNDO"; desde: 2; hasta: 30; valor: w.b.turbo; sufijo: "/s"
                    onMovido: (v) => w.cambiar({ turbo: v })
                }
                Column {
                    visible: w.b.modo === "mantener"
                    width: parent.width; spacing: 8
                    Mono { text: "AL MANTENERLO"; color: Pal.texto2; font.pixelSize: 10 }
                    Flow {
                        width: parent.width; spacing: 8
                        Repeater {
                            model: [["mando", "BOTÓN DEL MANDO"], ["tecla", "TECLA"], ["raton", "RATÓN"]]
                            Boton { texto: modelData[1]; tam: 10; implicitHeight: 26; activo: w.mantTipo === modelData[0]; onPulsado: w.mantTipoElegido = modelData[0] }
                        }
                    }
                    Flow {
                        width: parent.width; spacing: 6
                        Repeater {
                            model: w.mantTipo === "tecla" ? w.cat.teclas : w.mantTipo === "raton" ? w.cat.raton : w.cat.mando
                            Boton {
                                texto: modelData.indexOf("KEY_") === 0 ? modelData.substring(4) : w.nombreDe(modelData)
                                tam: 10; implicitHeight: 26
                                activo: w.b.mantener === modelData
                                onPulsado: w.cambiar({ mantener: modelData })
                            }
                        }
                    }
                    Deslizador {
                        etiqueta: "CUÁNTO MANTENER"; desde: 150; hasta: 1000; paso: 50; valor: w.b.mantenerMs; sufijo: " ms"
                        onMovido: (v) => w.cambiar({ mantenerMs: v })
                    }
                }
            }

            // Giroscopio
            Item { width: 1; height: 6 }
            Seccion { texto: "GIROSCOPIO (APUNTAR MOVIENDO EL MANDO)"; width: parent.width }
            Flow {
                width: parent.width; spacing: 8
                Boton { texto: "APAGADO"; activo: w.perfil.gyro.modo === "off"; onPulsado: w.cambiarGyro({ modo: "off" }) }
                Boton { texto: "COMO RATÓN"; activo: w.perfil.gyro.modo === "raton"; onPulsado: w.cambiarGyro({ modo: "raton", sensibilidad: 2.0 }) }
                Boton { texto: "COMO STICK DERECHO"; activo: w.perfil.gyro.modo === "joystick"; onPulsado: w.cambiarGyro({ modo: "joystick", sensibilidad: 100 }) }
            }
            Column {
                visible: w.perfil.gyro.modo !== "off"
                width: parent.width; spacing: 8
                Mono { text: "ACTIVO SIEMPRE O SOLO MIENTRAS MANTIENES UN BOTÓN"; color: Pal.texto2; font.pixelSize: 10 }
                Flow {
                    width: parent.width; spacing: 6
                    Boton { texto: "SIEMPRE"; tam: 10; implicitHeight: 26; activo: !w.perfil.gyro.activar; onPulsado: w.cambiarGyro({ activar: "" }) }
                    Repeater {
                        model: ["LM", "RM", "M2", "M1", "M4", "M3", "LB", "RB", "LS", "RS", "C", "Z"]
                        Boton { texto: w.nombreDe(modelData).replace("MINI GATILLO ", "").replace("PALETA ", "").replace("BOTÓN ", ""); tam: 10; implicitHeight: 26
                                activo: w.perfil.gyro.activar === modelData; onPulsado: w.cambiarGyro({ activar: modelData }) }
                    }
                }
                Mono {
                    visible: !!w.perfil.gyro.activar && !!w.perfil.botones[w.perfil.gyro.activar]
                    width: parent.width; wrapMode: Text.Wrap; color: Pal.alerta; font.pixelSize: 11; tracking: 0.5
                    text: "Ojo: " + w.nombreDe(w.perfil.gyro.activar) + " también tiene otra función en este perfil; al mantenerlo hará las dos cosas."
                }
                Deslizador {
                    etiqueta: "SENSIBILIDAD"
                    desde: w.perfil.gyro.modo === "raton" ? 0.5 : 20
                    hasta: w.perfil.gyro.modo === "raton" ? 8 : 250
                    paso: w.perfil.gyro.modo === "raton" ? 0.25 : 5
                    valor: w.perfil.gyro.sensibilidad
                    onMovido: (v) => w.cambiarGyro({ sensibilidad: v })
                }
            }
            Item { width: 1; height: 10 }
        }
    }

    component Deslizador: Row {
        id: d
        property string etiqueta
        property real desde: 0; property real hasta: 10; property real paso: 1; property real valor: 0
        property string sufijo: ""
        signal movido(real v)
        spacing: 14
        Mono { text: d.etiqueta; color: Pal.texto2; font.pixelSize: 10; width: 150; anchors.verticalCenter: parent.verticalCenter }
        Slider {
            id: s
            width: 260; from: d.desde; to: d.hasta; stepSize: d.paso; value: d.valor
            onMoved: d.movido(value)
            background: Item {
                x: s.leftPadding; y: s.topPadding + s.availableHeight / 2 - 1
                width: s.availableWidth; height: 2
                Rectangle { anchors.fill: parent; color: Pal.linea }
                Rectangle { width: s.visualPosition * parent.width; height: 2; color: Pal.neon }
            }
            handle: Rectangle {
                x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
                y: s.topPadding + s.availableHeight / 2 - height / 2
                width: 12; height: 12; rotation: 45; color: s.pressed ? Pal.texto : Pal.neon
            }
        }
        Mono { text: (d.paso < 1 ? d.valor.toFixed(2) : Math.round(d.valor)) + d.sufijo; color: Pal.neon; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
    }

    // ---------- pie ----------
    Rectangle {
        id: pie
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 34; color: Pal.panel
        Rectangle { width: parent.width; height: 1; color: Pal.linea }
        Mono {
            anchors.verticalCenter: parent.verticalCenter; x: 22; width: parent.width - 44; elide: Text.ElideRight
            text: w.avisoTexto || "Los cambios los hace padctl por software: no se escribe nada dentro del mando."
            color: w.avisoTexto ? (w.avisoError ? Pal.alerta : Pal.neon) : Pal.anclado
            font.pixelSize: 10
        }
    }

    // ---------- diálogo de confirmación ----------
    Rectangle {
        anchors.fill: parent; visible: w.confirmar !== ""; color: "#CC000000"
        MouseArea { anchors.fill: parent }
        Item {
            anchors.centerIn: parent; width: 520; height: 210
            Chaflan { anchors.fill: parent; tl: 16; br: 16; relleno: Pal.panel; borde: Pal.neon; grosor: 1.5 }
            Column {
                anchors.fill: parent; anchors.margins: 26; spacing: 14
                Text {
                    color: Pal.texto; font.family: Pal.titulo; font.pixelSize: 17; font.bold: true; font.letterSpacing: 2
                    text: w.confirmar === "aplicar" ? "APLICAR AL MANDO"
                        : w.confirmar === "borrar" ? "BORRAR PERFIL"
                        : w.confirmar === "original" ? "VOLVER A DE FÁBRICA"
                        : "CAMBIOS SIN GUARDAR"
                }
                Mono {
                    width: parent.width; wrapMode: Text.Wrap; color: Pal.texto2; font.pixelSize: 11; tracking: 0.5; lineHeight: 1.3
                    text: w.confirmar === "aplicar" ? "Se guardará «" + w.slug(nombreCampo.text) + "» y padctl lo usará en el mando ahora mismo. Si un juego está abierto, los botones cambiarán al momento."
                        : w.confirmar === "borrar" ? "Se borrará el perfil «" + w.anterior + "». No se puede deshacer."
                        : w.confirmar === "original" ? "El mando volverá a funcionar con todos los botones como vienen. Tus perfiles no se borran."
                        : "Hay cambios sin guardar en «" + w.slug(nombreCampo.text) + "». Si cambias de perfil se perderán."
                }
                Row {
                    spacing: 10; anchors.right: parent.right
                    Boton { texto: "CANCELAR"; onPulsado: w.confirmar = "" }
                    Boton {
                        fuerte: true; peligro: w.confirmar === "borrar" || w.confirmar.indexOf("cambiar:") === 0
                        texto: w.confirmar === "borrar" ? "BORRAR" : w.confirmar.indexOf("cambiar:") === 0 ? "DESCARTAR" : "ACEPTAR"
                        onPulsado: {
                            var c = w.confirmar; w.confirmar = ""
                            if (c === "aplicar") { var n = w.guardar(); if (n || !w.sucio) backend.aplicar(n || w.anterior) }
                            else if (c === "borrar") { if (backend.borrar(w.anterior)) { w.lista = backend.perfiles(); if (w.lista.length) { w.cargar(w.lista[0]); nombreCampo.text = w.lista[0] } else w.nuevo(false) } }
                            else if (c === "original") backend.original()
                            else if (c.indexOf("cambiar:") === 0) { var p = c.substring(8); w.cargar(p); nombreCampo.text = p }
                        }
                    }
                }
            }
        }
    }
}
