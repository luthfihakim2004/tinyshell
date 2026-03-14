import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

ColumnLayout {
  id: root
  spacing: 30

  Repeater {
    model: Hyprland.workspaces
    Rectangle {
      width: 14; height: 14; radius: 7
      color: modelData.active ? "#ffffff" : "#1a1a1a"
      //border.width: 0
      //border.color: modelData.active ? "#ffffff" : "#ffffff"

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace " + modelData.id)
      }
    }
  }

  // Fallback when no workspaces
  Text {
    visible: Hyprland.workspaces.length === 0
    text: "No WS"
    color: "#ffffffaa"
    font.pixelSize: 12
  }
}
