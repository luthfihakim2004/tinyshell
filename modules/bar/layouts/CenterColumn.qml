import QtQuick
Column {
  id: root
  spacing: 10
  // Critical: do NOT fill width; let it size to content
  // It will be horizontally centered by Bar.qml anchors
  default property alias content: root.data
}
