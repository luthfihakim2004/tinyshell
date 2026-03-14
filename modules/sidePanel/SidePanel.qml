import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../services"
import "."

PanelWindow {
  id: panel
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  WlrLayershell.exclusiveZone: 0

  anchors { top: true; left: true; bottom: true }
  margins { top: 5; left: 10; bottom: 5 }

  implicitWidth: PanelState.sidebarOpen ? 280 : 0

  property int selectedIndex: 0

  // Grab keyboard focus when opened so typing works immediately
  onImplicitWidthChanged: {
    if (PanelState.sidebarOpen)
      searchField.forceActiveFocus()
    else
      AppLauncher.query = ""
  }

  Item {
    anchors.fill: parent
    clip: true

    Behavior on width {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }

    Rectangle {
      anchors.fill: parent
      anchors.rightMargin: 8
      radius: 12
      color: "#121212"
      opacity: PanelState.sidebarOpen ? 1.0 : 0.0

      Behavior on opacity {
        NumberAnimation { duration: 200 }
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Search bar
        Rectangle {
          Layout.fillWidth: true
          height: 38
          radius: 8
          color: "#1e1e1e"
          border.color: searchField.activeFocus ? "#7c6af7" : "#2a2a2a"
          border.width: 1

          Behavior on border.color {
            ColorAnimation { duration: 150 }
          }

          RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Text {
              text: ""   // search icon
              color: "#666666"
              font.pixelSize: 14
              font.family: "Mononoki Nerd Font"
            }

            TextInput {
              id: searchField
              Layout.fillWidth: true
              color: "#ffffff"
              font.pixelSize: 13
              font.family: "Mononoki Nerd Font"
              selectByMouse: true
              clip: true

              // Placeholder text
              Text {
                anchors.fill: parent
                text: "Search apps..."
                color: "#444444"
                font.pixelSize: 13
                font.family: "Mononoki Nerd Font"
                visible: searchField.text === ""
              }

              onTextChanged: AppLauncher.query = text

              Keys.onUpPressed: {
                selectedIndex = Math.max(0, selectedIndex - 1)
                listView.positionViewAtIndex(selectedIndex, ListView.Contain)
              }
              Keys.onDownPressed: {
                selectedIndex = Math.min(
                    AppLauncher.results.length - 1,
                    selectedIndex + 1
                )
                listView.positionViewAtIndex(selectedIndex, ListView.Contain)
              }
              Keys.onReturnPressed: {
                if (AppLauncher.results.length > 0)
                    AppLauncher.launch(AppLauncher.results[selectedIndex])
              }
              Keys.onEscapePressed: {
                PanelState.sidebarOpen = false
              }
            }

            // Clear button
            Text {
              text: "✕"
              color: "#444444"
              font.pixelSize: 11
              visible: searchField.text !== ""

              MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                onClicked: searchField.text = ""
                cursorShape: Qt.PointingHandCursor
              }
            }
          }
        }

        // Track keyboard-selected index
        //property int selectedIndex: 0

        // Reset selection when results change
        Connections {
          target: AppLauncher
          function onResultsChanged() {
            panel.selectedIndex = 0
            listView.positionViewAtBeginning()
          }
        }

        // Results list
        ListView {
          id: listView
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 2
          model: AppLauncher.results

          ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
          }

          delegate: AppEntry {
            required property var modelData
            required property int index
            width: listView.width
            app: modelData
            selected: index === panel.selectedIndex

            onClicked: AppLauncher.launch(modelData)

            // Mouse hover also moves keyboard selection
            HoverHandler {
              onHoveredChanged: {
                if (hovered)
                  panel.selectedIndex = index
              }
            }
          }
        }
      }
    }
  }
}
