import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "."

PanelWindow {
    id: win

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Top-center anchor
    anchors { top: true; left: true; right: true }
    // Fixed height — tall enough for stacked notifications
    implicitHeight: 600
    // No exclusive zone — floats over everything
    WlrLayershell.exclusiveZone: -1
    mask: Region {
        item: notifStack
    }
    // Center the stack horizontally
    Item {
        anchors.fill: parent

        ColumnLayout {
          id: notifStack
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                // Show max 3 popups at once
                model: Notification.popups.slice(0, 3)

                delegate: Item {
                    id: cardWrapper

                    required property var modelData
                    required property int index

                    width: notifCard.width
                    height: notifCard.height

                    // Slide in from above + fade in
                    opacity: 0
                    transform: Translate { id: slideIn; y: -30 }

                    HoverHandler {
                      id: hover
                      onHoveredChanged: {
                        cardWrapper.modelData.dismissTimer.running = !hovered
                      }
                    }
                    
                    Card {
                        id: notifCard
                        notif: cardWrapper.modelData
                        onDismissRequested: cardWrapper.modelData.close()
                    }

                    // Enter animation
                    Component.onCompleted: enterAnim.start()

                    ParallelAnimation {
                        id: enterAnim
                        NumberAnimation {
                            target: cardWrapper
                            property: "opacity"
                            from: 0; to: 1
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: slideIn
                            property: "y"
                            from: -30; to: 0
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
