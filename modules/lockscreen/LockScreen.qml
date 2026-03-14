import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Services.Mpris
import "../../services/"

Item {
  id: root

  IdleMonitor {
    id: idleMonitor
    timeout: 180  // temporarily set to 10 seconds for testing
    onIsIdleChanged: {
      //console.log("isIdle changed:", isIdle)
      if (isIdle) lock.locked = true
    }
  }
  
  WlSessionLock {
    id: lock
    //onLockedChanged: console.log("lock.locked changed:", locked)
    //onSecureChanged: console.log("lock.secure changed:", secure)


    WlSessionLockSurface {
      id: surface

      readonly property string username: Quickshell.env("USER")
      readonly property var activePlayer: {
        const players = Mpris.players
        for (let i = 0; i < players.values.length; i++) {
          if (players.values[i].isPlaying) return players.values[i]
        }
        return players.values.length > 0 ? players.values[0] : null
      }

      Keys.onPressed: event => {
        if (!passwordField.activeFocus) {
          if (event.text.length > 0) {
            passwordField.forceActiveFocus()
            passwordField.text += event.text
            focusTimeout.restart()
            event.accepted = true
          }
        }
      }

      PamContext {
        id: pam
        user: surface.username
        config: "login"

        // PAM is asking for a response (password prompt)
        onResponseRequiredChanged: {
          if (responseRequired && passwordField.text.length > 0)
            pam.respond(passwordField.text)
        }

        // PAM sent a message — could be prompt or error
        onPamMessage: {
          if (messageIsError) {
            errorMsg.text = message
            errorMsg.visible = true
          }
        }

        // Authentication finished
        onCompleted: result => {
          if (result === PamResult.Success) {
            errorMsg.visible = false
            lock.locked = false
          } else {
            errorMsg.text = "Incorrect password"
            errorMsg.visible = true
            shakeAnim.start()
            passwordField.text = ""
            passwordField.forceActiveFocus()
          }
        }
      }

      // Background
      Rectangle {
        anchors.fill: parent

        Image{
          id: imgBg
          anchors.fill: parent
          source: "file:///home/leich/Pictures/fav/__souryuu_asuka_langley_neon_genesis_evangelion_and_2_more_drawn_by_haohaomaster__a38c01da12295a7762712b659c04f6bc.jpg"
          fillMode: Image.PreserveAspectCrop
          asynchronous: true

          Rectangle{
            anchors.fill: parent
            color: "black"
            visible: parent.status !== Image.Ready
          }
        }

        MultiEffect {
          id: bgBlur
          source: imgBg
          anchors.fill: imgBg
          blurEnabled: true
          blur: 1.0
          blurMax: 64
          opacity: passwordField.activeFocus ? 1.0 : 0.0
          Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
          }
        }

        // Create 3 Column Layout (left, center, right)
        Row{
          anchors.fill: parent
          anchors.margins: 60

          // LEFT
          Item {
            id: leftRow
            width: parent.width / 3
            height: parent.height

            // Card wraps the clock — sizes to content, not to leftRow
            Rectangle {
              id: clockCard
              anchors.centerIn: parent
              radius: 16
              color: "transparent"
              border.color: "#ffffff"
              border.width: 0
              implicitWidth: clockInner.implicitWidth + 48
              implicitHeight: clockInner.implicitHeight + 48

              Rectangle {
                id: clockBg
                anchors.fill: parent
                radius: parent.radius
                color: "#60ffffff"
                opacity: 0
                visible: false
              }

              MultiEffect {
                source: clockBg
                anchors.fill: clockBg
                shadowEnabled: false
                blurEnabled: false
                blur: 1.0
                //blurMultiplier: 1.0
                blurMax: 16
              }
              
              ColumnLayout {
                id: clockInner
                anchors.centerIn: parent
                spacing: 8

                Text {
                  id: clockH
                  Layout.alignment: Qt.AlignCenter
                  color: "#ffffff"
                  font.pixelSize: 96
                  font.family: "Mononoki Nerd Font"
                  font.weight: Font.Light
                  text: Qt.formatTime(new Date(), "hh")
                }

                Text {
                  id: clockM
                  Layout.alignment: Qt.AlignCenter
                  color: "#ffffff"
                  font.pixelSize: 96
                  font.family: "Mononoki Nerd Font"
                  font.weight: Font.Light
                  text: Qt.formatTime(new Date(), "mm")
                }

                Text {
                  id: clockDate
                  Layout.alignment: Qt.AlignLeft
                  color: "#cccccc"
                  font.pixelSize: 16
                  font.family: "Mononoki Nerd Font"
                  text: Qt.formatDate(new Date(), "dddd, MMMM d")
                }

                Timer {
                  interval: 1000
                  running: true
                  repeat: true
                  onTriggered: {
                    const now = new Date()
                    clockH.text = Qt.formatTime(now, "hh")
                    clockM.text = Qt.formatTime(now, "mm")
                  }
                }
              }
            }
          }

          // CENTER 
          Item {
            id: centerRow
            width: parent.width / 3 
            height: parent.height

            ColumnLayout{
              anchors.centerIn: parent
              spacing: 10

              // Profile Picture
              Rectangle{
                id: bgPic
                width: 192
                height: 192
                radius: width/2
                color: "#802a2a2a"
                Layout.alignment: Qt.AlignHCenter
                layer.enabled: true

                Image{
                  id: profilePic 
                  anchors.centerIn: parent
                  width: parent.width
                  height: parent.height
                  source: "file:///home/" + surface.username + "/.face"
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                  visible: false
                }

                MultiEffect{
                  source: profilePic
                  anchors.fill: profilePic 
                  maskEnabled: true
                  maskSource: mask 
                }

                Item{
                  id: mask
                  width: parent.width
                  height: parent.height
                  layer.enabled: true
                  visible: false

                  Rectangle{
                    width: parent.width
                    height: parent.height
                    radius: width/2
                    color: "black"
                  }
                }
                  
                Text {
                  anchors.centerIn: parent
                  text: surface.username.charAt(0).toUpperCase()
                  color: "#ffffff"
                  font.pixelSize: 36
                  font.family: "Mononoki Nerd Font"
                  visible: profilePic.status !== Image.Ready
                }
              }

              // Username display
              Text{
                Layout.alignment: Qt.AlignHCenter
                text: surface.username
                color: "#ffffff"
                font.pixelSize: 45
                font.family: "Mononoki Nerd Font"

                Component.onCompleted: {
                  console.log("surface.username:", surface.username)
                }
              }

              // Password Box
              Item {
                Layout.alignment: Qt.AlignHCenter
                width: passwordBox.width
                height: passwordBox.height

                SequentialAnimation {
                  id: shakeAnim
                  NumberAnimation { target: passwordBox; property: "x"; from: 0; to: -10; duration: 50 }
                  NumberAnimation { target: passwordBox; property: "x"; from: -10; to: 10; duration: 50 }
                  NumberAnimation { target: passwordBox; property: "x"; from: 10; to: -10; duration: 50 }
                  NumberAnimation { target: passwordBox; property: "x"; from: -10; to: 0; duration: 50 }
                }

                // Focus timeout — unfocuses after 5s of inactivity
                Timer {
                  id: focusTimeout
                  interval: 5000
                  repeat: false
                  onTriggered: {
                    passwordField.focus = false
                    passwordField.text = ""
                    errorMsg.visible = false
                    pam.abort()
                  }
                }

                Rectangle {
                  id: passwordBox
                  width: 280
                  height: 44
                  radius: 12
                  color: "#60ffffff"
                  border.color: passwordField.activeFocus ? "#ffffffff" : "#00ffffff"
                  border.width: 1

                  Behavior on border.color { ColorAnimation { duration: 150 } }
                  
                  // Click anywhere on the box to focus
                  MouseArea {
                    anchors.fill: parent
                    onClicked: {
                      passwordField.forceActiveFocus()
                      focusTimeout.restart()
                    }
                    cursorShape: Qt.PointingHandCursor
                  }
                  
                  RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                      text: ""
                      color: "#ffffff"
                      font.pixelSize: 14
                      font.family: "Mononoki Nerd Font"
                    }

                    Row {
                      spacing: 6
                      Layout.fillWidth: true
                      Repeater {
                        model: passwordField.text.length
                        Rectangle {
                          width: 7; height: 7; radius: 4
                          color: "#ffffff"
                          anchors.verticalCenter: parent.verticalCenter
                        }
                      }
                    }
                  }

                  TextInput {
                    id: passwordField
                    anchors.fill: parent
                    opacity: 0
                    echoMode: TextInput.Password
                    color: "#ffffff"
                    focus: false

                    Keys.onPressed: event => {
                      focusTimeout.restart()   // reset timer on every keypress
                    }

                    Keys.onReturnPressed: {
                      if (!activeFocus) {
                        forceActiveFocus()
                        focusTimeout.restart()
                      } else if (text.length > 0) {
                        errorMsg.visible = false
                        pam.start()
                      }
                    }
                    Keys.onEscapePressed: {
                      text = ""
                      errorMsg.visible = false
                      pam.abort()
                      focus = false
                      focusTimeout.stop()
                    }
                  }
                }
              }

              // wrong msg fallback
              Text {
                id: errorMsg
                Layout.alignment: Qt.AlignHCenter
                text: "Incorrect password"
                color: "#ff5555"
                font.pixelSize: 12
                font.family: "Mononoki Nerd Font"
                visible: false
              }
            }
          }

          // RIGHT 
          Item {
            id: rightRow
            width: parent.width / 3 
            height: parent.height

            ColumnLayout{
              anchors.centerIn: parent
              width: 350
              spacing: 16

              // MPRIS Player
              Rectangle{
                Layout.fillWidth: true
                height: 120
                radius: 16
                color: "#60ffffff"
                visible: surface.activePlayer !== null

                RowLayout{
                  anchors.fill: parent
                  anchors.margins: 16
                  spacing: 14

                  // Art
                  Rectangle{
                    width: 72; height: 72
                    radius: 10
                    color: "#2a2a2a"
                    clip: true

                    Image{
                      id: albumArt
                      anchors.fill: parent
                      source: surface.activePlayer?.trackArtUrl ?? ""
                      fillMode: Image.PreserveAspectCrop
                      visible: status === Image.Ready
                      Component.onCompleted:{
                        console.log(surface.activePlayer)
                      }
                    }

                    // Fallback 
                    Text{
                      anchors.centerIn: parent
                      text: ""
                      color: "#444444"
                      font.pixelSize: 28
                      font.family: "Mononoki Nerd Font"
                      visible: albumArt.status !== Image.Ready
                    }
                  }

                  // Track info + controls
                  ColumnLayout{
                    Layout.fillWidth: true
                    spacing: 4 

                    Text{
                      text: surface.activePlayer?.trackTitle || "Unknown"
                      color: "#ffffff"
                      font.pixelSize: 16
                      font.bold: true
                      font.family: "Mononoki Nerd Font"
                      Layout.fillWidth: true
                      elide: Text.ElideRight
                    }

                    Text {
                      text: surface.activePlayer?.trackArtist || ""
                      color: "#cccccc"
                      font.pixelSize: 13
                      font.family: "Mononoki Nerd Font"
                      Layout.fillWidth: true
                      elide: Text.ElideRight
                    }

                    // Controls 
                    Row{
                      spacing: 16
                      Layout.topMargin: 6

                      // Previous
                      Text {
                        text: "󰒮"
                        color: surface.activePlayer?.canGoPrevious ? "#ffffff" : "#444444"
                        font.pixelSize: 20
                        font.family: "Mononoki Nerd Font"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: surface.activePlayer?.previous()
                            cursorShape: Qt.PointingHandCursor
                        }
                      }

                      // Play/Pause
                      Text {
                        text: surface.activePlayer?.isPlaying ? "󰏤" : "󰐊"
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.family: "Mononoki Nerd Font"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: surface.activePlayer?.togglePlaying()
                            cursorShape: Qt.PointingHandCursor
                        }
                      }

                      // Next
                      Text {
                        text: "󰒭"
                        color: surface.activePlayer?.canGoNext ? "#ffffff" : "#444444"
                        font.pixelSize: 20
                        font.family: "Mononoki Nerd Font"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: surface.activePlayer?.next()
                            cursorShape: Qt.PointingHandCursor
                        }
                      }
                    }
                  }
                }
              }

              // Notification
              Rectangle{
                Layout.fillWidth: true
                radius: 16
                color: "#60ffffff"
                visible: Notification.list.length > 0
                implicitHeight: notifLayout.implicitHeight + 24

                ColumnLayout{
                  id: notifLayout
                  anchors{
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 12
                  }
                  spacing: 8

                  Repeater{
                    model: Notification.list.slice(0, 3)

                    delegate: Rectangle{
                      required property var modelData
                      Layout.fillWidth: true
                      height: 64
                      radius: 10
                      color: "#1a1a1a"

                      ColumnLayout{
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 2

                        Text {
                          text: modelData.summary || ""
                          color: "#ffffff"
                          font.pixelSize: 12
                          font.bold: true
                          font.family: "Mononoki Nerd Font"
                          Layout.fillWidth: true
                          elide: Text.ElideRight
                        }

                        Text {
                          text: (modelData.body || "").replace(/\n/g, " ")
                          color: "#888888"
                          font.pixelSize: 11
                          font.family: "Mononoki Nerd Font"
                          Layout.fillWidth: true
                          elide: Text.ElideRight
                          textFormat: Text.StyledText
                        }
                      }
                    }
                  }
                }
              }

              // Fallback notif & player
              Text {
                Layout.alignment: Qt.AlignHCenter
                text: "No notifications"
                color: "#333333"
                font.pixelSize: 12
                font.family: "Mononoki Nerd Font"
                visible: surface.activePlayer === null && Notification.list.length === 0
              }
            }
          }
        }

      // Global key catcher for WlSessionLockSurface
      Item {
        anchors.fill: parent
        focus: !passwordField.activeFocus  // grabs focus when field is unfocused

        Keys.onPressed: event => {
          if (event.text.length > 0) {
            passwordField.forceActiveFocus()
            passwordField.text += event.text
            focusTimeout.restart()
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            passwordField.forceActiveFocus()
            focusTimeout.restart()
            event.accepted = true
          }
        }
      }
      }

      Component.onCompleted: {
        //passwordField.focus = false
      }
    }
  }
}

