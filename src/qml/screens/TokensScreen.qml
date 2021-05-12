/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

// Screen for managing the Wallet's tokens.
Item {
  id: tokensScreen

  AVMEAccountHeader {
    id: accountHeader
  }

  AVMEPanel {
    id: tokensPanel
    anchors {
      top: accountHeader.bottom
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Available Tokens"

    Text {
      id: tokenText
      anchors {
        top: parent.header.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 20
      }
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 18.0
      text: "Select the token you wish to use."
    }

    AVMETokenGrid {
      id: tokenGrid
      anchors {
        top: tokenText.bottom
        bottom: btnRow.top
        horizontalCenter: parent.horizontalCenter
        margins: 20
      }
      width: 9 * tokenGrid.cellWidth
      model: ListModel {
        id: tokenList
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME2" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME3" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME4" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME5" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME6" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME7" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME8" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME9" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME10" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME11" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME12" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME13" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME14" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME15" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME16" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME17" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME18" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME19" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME20" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME21" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME22" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME23" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME24" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME25" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME26" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME27" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME28" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME29" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME30" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME31" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME32" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME33" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME34" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME35" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME36" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME37" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME38" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME39" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME40" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME41" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME42" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME43" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME44" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME45" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME46" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME47" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME48" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME49" }
        ListElement { image: "qrc:/img/avme_logo.png"; label: "AVME50" }
      }
    }

    Row {
      id: btnRow
      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 20
      }
      spacing: 20

      AVMEButton {
        id: btnAdd
        width: tokensPanel.width * 0.25
        text: "Add a new token"
      }
      AVMEButton {
        id: btnSelect
        width: tokensPanel.width * 0.25
        text: "Select this token"
      }
      AVMEButton {
        id: btnRemove
        width: tokensPanel.width * 0.25
        enabled: (tokenGrid.currentItem.itemLabel != "AVME")
        text: "Remove this token"
      }
    }
  }
}
