pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Thresholds in descending order — each fires once per discharge cycle
    readonly property var levels: [
        { pct: 20, title: "Low Battery",      body: "Consider plugging in soon.",     urgency: "normal"   },
        { pct: 90, title: "Very Low Battery", body: "Plug in your charger now.",      urgency: "critical" },
        { pct:  5, title: "Critical Battery", body: "System will shut down shortly.", urgency: "critical" }
    ]

    // Tracks which thresholds have already fired this discharge cycle
    // so they don't spam every 30 seconds
    property var fired: new Set()

    FileView {
        id: capacityFile
        path: "/sys/class/power_supply/BAT1/capacity"
    }

    FileView {
        id: statusFile
        path: "/sys/class/power_supply/BAT1/status"
    }

    readonly property int pct: Math.min(100, parseInt(capacityFile.text().trim()) || 0)
    readonly property string status: statusFile.text().trim()

    // Reset fired set when charger is plugged in
    // so thresholds fire again on the next discharge
    onStatusChanged: {
        if (status === "Charging" || status === "Full")
            fired = new Set()
    }

    Timer {
        interval: 30000   // check every 30 seconds
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload()
            statusFile.reload()
            root.check()
        }
    }

    function check(): void {
        // Don't alert while charging or full
        if (status === "Charging" || status === "Full" || status === "Not charging")
            return

        for (const level of levels) {
            if (pct <= level.pct && !fired.has(level.pct)) {
                fired.add(level.pct)
                // Re-assign to trigger onFiredChanged reactivity
                fired = new Set(fired)
                notify(level)
            }
        }
    }

    function notify(level): void {
        notifyProcess.command = [
            "notify-send",
            "--urgency=" + level.urgency,
            "--icon=battery-caution",
            level.title,
            level.body + " (" + pct + "%)"
        ]
        notifyProcess.running = true
    }

    Process {
        id: notifyProcess
        command: []
    }
}
