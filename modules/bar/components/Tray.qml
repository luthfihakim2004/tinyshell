import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Column {
  spacing: 6
  Layout.alignment: Qt.AlignHCenter
  Layout.fillWidth: true
  Component.onCompleted: {
   // console.log("values length:", SystemTray.items.values.length)
   // console.log("values type:", typeof SystemTray.items.values)
   // console.log("items keys:", JSON.stringify(Object.keys(SystemTray.items)))
   // console.log("items.values keys:", JSON.stringify(Object.keys(SystemTray.items.values).slice(0, 5)))
  }
  Connections {
    target: SystemTray.items
    function onObjectInsertedPost(obj, idx) {
      //console.log("Tray item added:", obj.title, obj.icon)
    }
  }
    Repeater {
        model: {
        const v = SystemTray.items.values
        void SystemTray.items.valuesChanged  // force re-evaluation on change
        return v.length
      }

        delegate: Item {
          required property int index
          readonly property var trayItem: SystemTray.items.values[index]

            width: 28
            height: 28
            anchors.horizontalCenter: parent.horizontalCenter

            IconImage {
              id: trayIcon
              anchors.fill: parent
              source: {
                  if (!trayItem?.icon) return ""
                  // Already a full URI (image://... or file://... or http...)
                  if (trayItem.icon.startsWith("image://") || 
                      trayItem.icon.startsWith("file://") ||
                      trayItem.icon.startsWith("/"))
                      return trayItem.icon
                  // Bare icon name — use xdgicon provider
                  return "image://xdgicon/" + trayItem.icon
              }
            }

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: "#2a2a2a"
                visible: trayIcon.status !== Image.Ready

                Text {
                    anchors.centerIn: parent
                    text: trayItem?.title ? trayItem.title.charAt(0) : "?"
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.family: "Mononoki Nerd Font"
                }
            }

          QsMenuOpener {
            id: menuOpener
            menu: trayItem?.menu ?? null
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
        if (mouse.button === Qt.LeftButton && !trayItem?.onlyMenu) {
            trayItem?.activate()
        } else {
            // display() shows the platform menu at the click position
            trayItem?.display(trayIcon.QsWindow.window, mouse.x, mouse.y)
        }
            }
          }
        }
    }
}
