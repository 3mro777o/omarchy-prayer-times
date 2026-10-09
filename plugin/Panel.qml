import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Full-day popup: countdown hero, dates, and the six times with iqama.
Panel {
  id: root
  moduleName: "blacknova.prayer-times"
  ipcTarget: "blacknova.prayer-times"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  readonly property color fg: bar ? bar.foreground : Color.foreground
  readonly property string fontName: bar ? bar.fontFamily : Style.font.family
  readonly property var host: hostWidget
  readonly property string lang: host ? host.lang : "en"
  function t(k) { return Model.tr(root.lang, k) }
  readonly property date now: host ? host.now : new Date()
  // After isha the table rolls over to tomorrow, where the next adhan is.
  readonly property date tableDay: next ? next.time : now
  readonly property bool tomorrow: tableDay.getDate() !== now.getDate()
  readonly property var today: host ? Model.dayTimes(host.mawaqit, tableDay, lang) : []
  readonly property var next: host ? host.next : null
  readonly property var previous: host ? host.previous : null
  readonly property real progress: (next && previous)
    ? Math.max(0, Math.min(1, (now - previous.time) / (next.time - previous.time))) : 0

  function open() { root.controller.show() }
  function close() { root.controller.hide() }
  function toggle() { if (root.opened) close(); else open() }
  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(400))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(14)
        LayoutMirroring.enabled: root.lang === "ar"
        LayoutMirroring.childrenInherit: true

        // ---- Hero: countdown to the next adhan.
        Column {
          width: parent.width
          spacing: Style.space(4)

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.next ? root.t("adhanIn").replace("%1", root.next.name) : root.t("loading")
            color: Qt.darker(root.fg, 1.4)
            font.family: root.fontName
            font.pixelSize: Style.font.body
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.next !== null
            text: root.next ? Model.countdown(root.next.time - root.now, true, root.lang) : ""
            color: root.host && root.host.soon ? Color.accent : root.fg
            font.family: root.fontName
            font.pixelSize: 44
            font.bold: true
          }

          // progress from previous adhan to the next one
          Item {
            width: parent.width
            height: Style.space(14)
            visible: root.next !== null
            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter
              width: parent.width * 0.8
              height: 4
              radius: 2
              color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.12)
              Rectangle {
                anchors.left: parent.left
                width: parent.width * root.progress
                height: parent.height
                radius: 2
                color: Color.accent
              }
            }
          }
        }

        // ---- Mosque + dates
        Column {
          width: parent.width
          spacing: Style.space(3)
          Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.host ? root.host.mosqueName : ""
            color: root.fg
            font.family: root.fontName
            font.pixelSize: Style.font.body
            font.bold: true
          }
          Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: (root.tomorrow ? root.t("tomorrow") + "  ·  " : "") + Qt.locale(root.lang).toString(root.tableDay, "dddd d MMMM yyyy") + "  ·  "
              + Model.hijri(root.tableDay, root.host && root.host.mawaqit ? root.host.mawaqit.hijriAdjustment : 0, root.lang)
            color: Qt.darker(root.fg, 1.4)
            font.family: root.fontName
            font.pixelSize: Style.font.bodySmall
          }
        }

        Rectangle {
          width: parent.width
          height: Style.spacing.hairline
          color: root.fg
          opacity: 0.12
        }

        // ---- Header row
        Item {
          width: parent.width
          height: headerName.implicitHeight
          Text {
            id: headerName
            anchors.left: parent.left
            anchors.leftMargin: Style.space(16)
            text: root.t("prayer")
            color: Qt.darker(root.fg, 1.6)
            font.family: root.fontName
            font.pixelSize: Style.font.caption
          }
          Text {
            x: parent.width * 0.48
            text: root.t("adhan")
            color: Qt.darker(root.fg, 1.6)
            font.family: root.fontName
            font.pixelSize: Style.font.caption
          }
          Text {
            anchors.right: parent.right
            anchors.rightMargin: Style.space(16)
            text: root.t("iqama")
            color: Qt.darker(root.fg, 1.6)
            font.family: root.fontName
            font.pixelSize: Style.font.caption
          }
        }

        // ---- Times
        Column {
          width: parent.width
          spacing: Style.space(2)

          Repeater {
            model: root.today

            Rectangle {
              required property var modelData
              readonly property bool isNext: root.next !== null && modelData.key === root.next.key
                && modelData.time.getTime() === root.next.time.getTime()
              readonly property bool passed: modelData.time < root.now && !isNext
              width: parent.width
              height: Style.space(34)
              radius: Style.cornerRadius
              color: isNext ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.18) : "transparent"
              border.width: isNext ? 1 : 0
              border.color: Color.accent
              opacity: passed ? 0.45 : 1

              Text {
                anchors.left: parent.left
                anchors.leftMargin: Style.space(16)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.name
                color: isNext ? Color.accent : root.fg
                font.family: root.fontName
                font.pixelSize: Style.font.title
                font.bold: isNext
              }
              Text {
                x: parent.width * 0.48
                anchors.verticalCenter: parent.verticalCenter
                text: Model.hm(modelData.time)
                color: isNext ? Color.accent : root.fg
                font.family: root.fontName
                font.pixelSize: Style.font.title
                font.bold: isNext
              }
              Text {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(16)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.iqama ? Model.hm(modelData.iqama) : "—"
                color: Qt.darker(root.fg, 1.3)
                font.family: root.fontName
                font.pixelSize: Style.font.body
              }
            }
          }
        }

        Rectangle {
          width: parent.width
          height: Style.spacing.hairline
          color: root.fg
          opacity: 0.12
        }

        // ---- Actions, then display settings
        Repeater {
          model: [
            [
              { label: "󰓛  " + root.t("stop"), args: ["stop"] },
              { label: "󰐊  " + root.t("test"), args: ["test"] },
              { label: "󰑐  " + root.t("refresh"), args: ["fetch"] }
            ],
            [
              { label: "󰥔  " + root.t(root.host && root.host.showTime ? "showTime" : "showCountdown"),
                set: { barMode: root.host && root.host.showTime ? "countdown" : "time" } },
              { label: "󰗊  " + root.t("language"), set: { lang: root.lang === "ar" ? "en" : "ar" } }
            ]
          ]

          Row {
            id: btnRow
            required property var modelData
            // buttons keep the same order in both languages
            LayoutMirroring.enabled: false
            LayoutMirroring.childrenInherit: true
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.space(10)

            Repeater {
              model: btnRow.modelData

              Rectangle {
                required property var modelData
                width: btnText.implicitWidth + Style.space(24)
                height: Style.space(30)
                radius: Style.cornerRadius
                color: btnArea.containsMouse ? Style.hoverFillFor(root.fg, Color.accent) : "transparent"
                border.width: 1
                border.color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.2)

                Text {
                  id: btnText
                  anchors.centerIn: parent
                  text: modelData.label
                  color: btnArea.containsMouse ? Style.hoverStateColor(root.fg, Color.accent) : root.fg
                  font.family: root.fontName
                  font.pixelSize: Style.font.bodySmall
                }
                MouseArea {
                  id: btnArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: modelData.set ? root.host.persistSettings(modelData.set)
                    : Quickshell.execDetached([root.host.cli].concat(modelData.args))
                }
              }
            }
          }
        }
      }
    }
  }
}
