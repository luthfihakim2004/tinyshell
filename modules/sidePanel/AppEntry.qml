import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
  id: entry

  required property var app
  required property bool selected

  signal clicked()

  height: 48
  radius: 8
  color: selected ? "#2a2a2a" : hoverHandler.hovered ? "#1f1f1f" : "transparent"

  Behavior on color {
    ColorAnimation { duration: 100 }
  }

  RowLayout {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 12

      // IconImage resolves theme icons, absolute paths, and fallbacksIconImage
      
    IconImage {
      id: appIcon
      width: 28
      height: 28
      source: entry.app.icon ? "image://icon/" + entry.app.icon : ""
      Layout.alignment: Qt.AlignVCenter

      // Fallback letter avatar when no icon found
      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#2a2a2a"
        visible: appIcon.status !== Image.Ready

        Text {
          anchors.centerIn: parent
          text: entry.app.name.charAt(0).toUpperCase()
          color: "#ffffff"
          font.pixelSize: 14
          font.family: "Mononoki Nerd Font"
        }
      }
            
        Component.onCompleted: {
          //console.log(appIcon.status!==Image.Ready);
          //console.log(entry.app.icon);
        }
      }

      Text {
        text: entry.app.name
        color: "#ffffff"
        font.pixelSize: 13
        font.family: "Mononoki Nerd Font"
        elide: Text.ElideRight
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
      }
  }

  HoverHandler {
    id: hoverHandler
  }

  MouseArea {
    anchors.fill: parent
    onClicked: entry.clicked()
    cursorShape: Qt.PointingHandCursor
  }
}
