import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io          // ← add this

PanelWindow {
    id: battwatcher
    visible: lowBattery
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: 0
    anchors { bottom: true; right: true }
    implicitWidth:  gif.width
    implicitHeight: gif.height
    color: "transparent"
    focusable: false

    property bool lowBattery: false
    readonly property int warnLevel: 10

    // ── Read capacity directly from sysfs ────────────────────────────────
    FileView {
        id: capacityFile
        path: "/sys/class/power_supply/BAT1/capacity"

        // Optional but recommended for system files:
        // Reloads content when the file changes on disk (inotify)
        watchChanges: true

        // The actual value as string → int
        readonly property int percent: text.trim() ? parseInt(text.trim()) : -1
    }

    Timer {
        interval: 1000          // 10 seconds – you can lower to 5000–30000
        running: true
        repeat: true

        onTriggered: {
            // Just force re-evaluation – FileView already watches
            // but this helps when watchChanges doesn't fire reliably
            capacityFile.reload()

            let pct = capacityFile.percent

            // Also check if we're on battery (very simple heuristic)
            // You can read /sys/class/power_supply/BAT1/status too if needed
            battwatcher.lowBattery = (pct >= 0 && pct <= warnLevel)
                                   // && on battery → optional extra check below
        }
    }

    // Optional: also watch charging status to know if we're really discharging
    FileView {
        id: statusFile
        path: "/sys/class/power_supply/BAT1/status"
        watchChanges: true

        readonly property bool discharging: text.trim() === "Discharging"
    }

    // Then use both in the condition if you want to be precise:
    // lowBattery = discharging && percent <= warnLevel

    AnimatedImage {
        id: gif
        anchors.centerIn: parent
        //source: "file:///home/leich/Pictures/lowbat.gif"
        visible: true
        playing: true
        fillMode: Image.PreserveAspectFit
        cache: true
        width: 600
        height: 550
    }
}
