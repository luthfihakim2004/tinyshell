import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    required property var notif
    signal dismissRequested()

    width: 380
    height: contentCol.implicitHeight + 24
    radius: 12
    color: "#1e1e1e"

    // Urgency accent bar
    Rectangle {
        width: 4
        height: parent.height - 16
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        radius: 2
        color: {
            if (notif.urgency === 2) return "#ff5555"
            if (notif.urgency === 0) return "#555555"
            return "#7c6af7"
        }
    }

    RowLayout {
        id: contentCol
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.margins: 16
        anchors.leftMargin: 20
        spacing: 10

        // Left: text content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            // Header row: app name + time + close button
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: notif.appName || "Unknown"
                    color: "#aaaaaa"
                    font.pixelSize: 11
                    font.family: "Mononoki Nerd Font"
                    Layout.fillWidth: true
                }

                Text {
                    text: notif.timeStr
                    color: "#666666"
                    font.pixelSize: 11
                    font.family: "Mononoki Nerd Font"
                }

                Text {
                    text: "✕"
                    color: "#666666"
                    font.pixelSize: 11
                    font.family: "Mononoki Nerd Font"
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: card.dismissRequested()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // Summary
            Text {
                text: notif.summary || ""
                color: "#ffffff"
                font.pixelSize: 15
                font.bold: true
                font.family: "Mononoki Nerd Font"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                visible: text !== ""
            }

            // Body
            Text {
                text: (notif.body || "").replace(/\n/g, "<br>")
                color: "#cccccc"
                font.pixelSize: 13
                font.family: "Mononoki Nerd Font"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                visible: text !== ""
            }
        }

      // Right: notification image
      Rectangle {
          visible: notif.resolvedImage !== ""
          width: 64
          height: 64
          radius: 8
          clip: true
          color: "transparent"
          Layout.alignment: Qt.AlignTop
          border.color: "#ffffff22"
          border.width: 1

          Image {
              anchors.fill: parent
              source: notif.resolvedImage !== "" ? Qt.resolvedUrl(notif.resolvedImage) : ""
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
          }
      }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: card.dismissRequested()
        z: -1
    }
}
