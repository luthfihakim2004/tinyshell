import QtQuick

Text {
    id: time
    color: "#ffffff"
    font.pixelSize: 18
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    font.family: "Mononoki Nerd Font"
    text: hours + "\n" + minutes

    property string hours: ""
    property string minutes: ""

    function updateNow() {
        const now = new Date()
        hours = Qt.formatTime(now, "hh")
        minutes = Qt.formatTime(now, "mm")
    }

    Component.onCompleted: {
        updateNow()
        // Sync: wait until the next whole minute, then switch to 60s interval
        const now = new Date()
        const msUntilNextMinute = (60 - now.getSeconds()) * 1000 - now.getMilliseconds()
        syncTimer.interval = msUntilNextMinute
        syncTimer.start()
    }

    // One-shot timer that fires exactly at the next minute boundary
    Timer {
        id: syncTimer
        repeat: false
        onTriggered: {
            time.updateNow()
            // Now switch to the regular 60s tick
            regularTimer.start()
        }
    }

    // Regular 60s tick after sync
    Timer {
        id: regularTimer
        interval: 60 * 1000
        running: false
        repeat: true
        onTriggered: time.updateNow()
    }
}
