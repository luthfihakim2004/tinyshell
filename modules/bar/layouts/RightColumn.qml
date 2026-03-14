import QtQuick
Column {
  id: root
  spacing: 10
  // pack items right-to-left so last item touches the edge if you prefer:
  // layoutDirection: Qt.RightToLeft
  default property alias content: root.data
}
