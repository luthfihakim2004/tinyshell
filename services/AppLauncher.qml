pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property string query: ""

  readonly property var allApps: {
    const vals = DesktopEntries.applications.values
    const result = []
    for (let i = 0; i < vals.length; i++) {
      const app = vals[i]
      if (app && app.name && !app.noDisplay)
        result.push(app)
    }
    return result.sort((a, b) => a.name.localeCompare(b.name))
  }

  readonly property var results: {
    if (!allApps || allApps.length === 0) return []
    if (query.trim() === "") return allApps
    const q = query.toLowerCase()
    return allApps.filter(a =>
      a.name.toLowerCase().includes(q) ||
      (a.genericName && a.genericName.toLowerCase().includes(q)) ||
      (a.keywords && a.keywords.some(k => k.toLowerCase().includes(q)))
    )
  }

  function launch(app): void {
    app.execute()
    query = ""
    PanelState.sidebarOpen = false
  }
}
