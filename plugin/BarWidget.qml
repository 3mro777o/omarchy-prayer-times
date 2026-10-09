import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Next prayer for El Iman Moschee Hamburg. Data comes from the cache that
// `prayer-times daemon` (systemd user service) keeps fresh from mawaqit;
// the daemon also does the 20-minute reminder and plays the adhan.
BarWidget {
  id: root
  moduleName: "blacknova.prayer-times"

  readonly property string home: Quickshell.env("HOME")
  readonly property string cli: home + "/.local/bin/prayer-times"

  property var mawaqit: null
  property date now: new Date()

  // Persisted in this widget's shell.json entry; the panel toggles them.
  readonly property string lang: settings && settings.lang === "ar" ? "ar" : "en"
  readonly property bool showTime: settings && settings.barMode === "time"

  readonly property var next: Model.nextPrayer(mawaqit, now, lang)
  readonly property var previous: Model.previousPrayer(mawaqit, now, lang)
  readonly property real remainingMs: next ? next.time.getTime() - now.getTime() : 0
  readonly property bool soon: next !== null && remainingMs <= 20 * 60000
  readonly property string mosqueName: mawaqit && mawaqit.name ? mawaqit.name : ""

  readonly property string label: next
    ? "󱠧 " + (lang === "ar" ? "\u2067" : "") + next.name + " "
      + (showTime ? Model.hm(next.time) : Model.countdown(remainingMs, false, lang))
      + (lang === "ar" ? "\u2069" : "")
    : (mawaqit ? "" : "󱠧")

  function run(args) { Quickshell.execDetached(args) }

  function persistSettings(values) {
    var entry = { id: root.moduleName }
    for (var k in root.settings) if (k !== "id") entry[k] = root.settings[k]
    for (var v in values) entry[v] = values[v]
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  FileView {
    id: cache
    path: root.home + "/.local/state/prayer-times/mawaqit.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { var d = Model.parse(text()); if (d) root.mawaqit = d }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  // ---- Popup plumbing, same contract as the built-in weather/clock widgets.
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false
  readonly property real openPanelIndicatorWidth: button.labelWidth

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function togglePanel() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.vertical ? "󱠧" : root.label
    hasVisualContent: root.label !== ""
    horizontalMargin: 8.75
    verticalPadding: 8.75
    foreground: root.soon ? Color.accent : (root.bar ? root.bar.barForeground : Color.foreground)

    onPressed: function(b) {
      if (b === Qt.RightButton) root.run([root.cli, "stop"])
      else if (b === Qt.MiddleButton) root.run([root.cli, "fetch"])
      else root.togglePanel()
    }
  }
}
