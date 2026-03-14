pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // Full list of all notifications (including dismissed ones
    // that are still animating out)
    property list<Notif> list: []

    // Only the ones still visible as popups
    readonly property list<Notif> popups: list.filter(n => n.popup)

    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true

            const obj = notifComp.createObject(root, {
                notification: notif,
                popup: true
            })
            // Prepend so newest is on top
            root.list = [obj, ...root.list]
        }
    }

    // Inline component — one instance per notification
    component Notif: QtObject {
        id: notif

        // Whether this notif is showing as a popup
        property bool popup: false
        // Set to true once dismissed — lets animation finish before removal
        property bool closed: false

        // Data fields — copied from the live Notification object
        // so they survive even after the notification is gone
        property string id
        property string summary
        property string body
        property string appIcon
        property string appName
        property string image
        property int urgency: NotificationUrgency.Normal
        property real expireTimeout: 5000

        // Time-ago display string
        property date time: new Date()
        property string timeStr: "now"

        // The live Quickshell notification object
        property Notification notification

        // Auto-dismiss timer
        property Timer dismissTimer: Timer {
            running: notif.popup
            // Use the app's requested timeout, fall back to 5s
            interval: notif.expireTimeout > 0 ? notif.expireTimeout : 5000
            onTriggered: notif.popup = false
        }
        // Resolves image from either the image hint or appIcon field
        // (some apps like Hyprshot send the image path as appIcon)
        readonly property string resolvedImage: {
            if (image && image !== "") return image
            if (appIcon && appIcon.startsWith("/")) return appIcon
            return ""
        }
        // Time-ago updater
        readonly property Timer timeStrTimer: Timer {
            running: !notif.closed
            repeat: true
            interval: 5000
            onTriggered: notif.updateTimeStr()
        }

        function updateTimeStr(): void {
            const diff = Date.now() - time.getTime()
            const m = Math.floor(diff / 60000)
            if (m < 1) {
                timeStr = "now"
                timeStrTimer.interval = 5000
            } else {
                const h = Math.floor(m / 60)
                const d = Math.floor(h / 24)
                if (d > 0) {
                    timeStr = d + "d"
                    timeStrTimer.interval = 3600000
                } else if (h > 0) {
                    timeStr = h + "h"
                    timeStrTimer.interval = 300000
                } else {
                    timeStr = m + "m"
                    timeStrTimer.interval = m < 10 ? 30000 : 60000
                }
            }
        }

        function close(): void {
            closed = true
            popup = false
            // Remove from global list and dismiss the D-Bus notification
            root.list = root.list.filter(n => n !== this)
            notification?.dismiss()
            destroy()
        }

        // Mirror live notification changes
        readonly property Connections conn: Connections {
            target: notif.notification

            function onClosed(): void { notif.close() }
            function onSummaryChanged(): void { notif.summary = notif.notification.summary }
            function onBodyChanged(): void { notif.body = notif.notification.body }
            function onAppIconChanged(): void { notif.appIcon = notif.notification.appIcon }
            function onAppNameChanged(): void { notif.appName = notif.notification.appName }
            function onExpireTimeoutChanged(): void { notif.expireTimeout = notif.notification.expireTimeout }
            function onUrgencyChanged(): void { notif.urgency = notif.notification.urgency }
        }

        Component.onCompleted: {
            if (!notification) return
            id = notification.id
            summary = notification.summary
            body = notification.body
            appIcon = notification.appIcon
            appName = notification.appName
            image = notification.image
            expireTimeout = notification.expireTimeout
            urgency = notification.urgency
        }
    }

    Component {
        id: notifComp
        Notif {}
    }
}
