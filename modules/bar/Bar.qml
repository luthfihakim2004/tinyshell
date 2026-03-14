import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./layouts/"
import "./components"
import "../../services/"

PanelWindow {
    id: panel
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    implicitWidth: 50
    WlrLayershell.exclusiveZone: implicitWidth
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; left: true; bottom: true }
    margins { top: 5; bottom: 5; left: 10; right: 10 }

    // Root item — critical, gives a proper Item parent
    // for all children to anchor against
    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#121212"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8

            // Top: toggle button
            Column {
              Layout.alignment: Qt.AlignHCenter
              Layout.fillWidth: true

              // Toggle button — tapping opens/closes sidebar
              Rectangle {
                width: 35; height: 35
                radius: 8
                color: PanelState.sidebarOpen ? "#9d9d9d9d" : "#fefefe"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                  anchors.centerIn: parent
                  text: ""   // Nerd Font icon, swap to whatever you like
                  color: "#000000"
                  font.pixelSize: 20
                  font.family: "Mononoki Nerd Font"
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: PanelState.toggle()
                }
              }
            }
            
            Tray {}

            Item { Layout.fillHeight: true }

            Column {
                Layout.alignment: Qt.AlignHCenter
                Workspaces {}
            }

            Item { Layout.fillHeight: true }

            Column {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Time { width: parent.width }
                Battery { width: parent.width }
            }
        }
    }
}
