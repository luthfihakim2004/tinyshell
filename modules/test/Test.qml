import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"

PanelWindow{
  id: root
  color: "black"
  WlrLayershell.layer: WlrLayer.Top
  implicitHeight: 300
  
  anchors { right: true; left: true; bottom: true }
  margins { top: 5; bottom: 5; left: 10; right: 10 }


  Item{
    anchors.fill: parent
    Rectangle{
      anchors.fill: parent
      color: "white"
    }
    RowLayout{
      anchors.fill: parent
      Layout.alignment: Qt.AlignCenter
      ListView{
        width: parent; height: parent
        model: AppLauncher {}
        delegate: Text {
          required property string name
          required property string genericName
          text: name + " " + genericName
        }
      }
    }
  }
}
