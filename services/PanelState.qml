pragma Singleton
import QtQuick

QtObject {
    id: root
    property bool sidebarOpen: false

    function toggle() {
        sidebarOpen = !sidebarOpen
    }
}
