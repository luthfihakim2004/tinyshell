import QtQuick
Column {
  id: root
  spacing: 10
  // width/height are implicit from children; no layouts so it won’t stretch
  default property alias content: root.data
}
