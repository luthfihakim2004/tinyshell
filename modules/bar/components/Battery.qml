import QtQuick
import Quickshell.Io

Text {
  id: batt
  color: "#ffffff"
  width: parent.width
  horizontalAlignment: Text.AlignHCenter
  verticalAlignment:   Text.AlignVCenter
  font.pixelSize: 15
  font.family: "Mononoki Nerd Font"
  text: icon() + "\n" + pct + "%"

  FileView {
      id: capacityFile
      path: "/sys/class/power_supply/BAT1/capacity"
  }

  FileView {
      id: statusFile
      path: "/sys/class/power_supply/BAT1/status"
  }

  readonly property var pct: Math.min(100, parseInt(capacityFile.text().trim()))
  readonly property var stat: statusFile.text().trim()

  function icon() {
      if (stat == "Charging") return ""
      if (stat == "Full" || stat == "Not charging") return "AC"
      if (pct > 90) return "󰂂"
      if (pct > 50) return "󰁾"
      if (pct > 30) return "󰁼"
      return "󰂎"
  }
  
  Timer {
      interval: 5000
      running: true
      repeat: true
      onTriggered: {
          capacityFile.reload()
          statusFile.reload()
      }
  }
  
}
