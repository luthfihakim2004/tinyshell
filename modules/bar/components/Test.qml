import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    id: root
    height: 34
    width: parent.width

    Rectangle {
        id: button
        width: parent.width
        height: parent.height
        radius: 7
        color: "#ffffff"

        Text {
            anchors.centerIn: parent
            text: "≡"
            color: "#000"
            font.pixelSize: 16
        }

        TapHandler {
            onTapped: launcher.running = true
        }

        HoverHandler {
            id: hover
        }

        opacity: hover.hovered ? 0.8 : 1.0
    }

    Process {
        id: launcher
        command: ["wofi", "--show", "drun"]
    }
}
