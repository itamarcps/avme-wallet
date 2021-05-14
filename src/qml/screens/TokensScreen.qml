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

  Component.onCompleted: reloadTokenList()

  function reloadTokenList() {
    tokenList.clear()
    var tokens = System.getTokenList()
    for (var i = 0; i < tokens.length; i++) {
      tokenList.append(JSON.parse(tokens[i]))
    }
  }

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
      model: ListModel { id: tokenList }
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
        onClicked: addTokenPopup.open()
      }
      AVMEButton {
        id: btnSelect
        width: tokensPanel.width * 0.25
        text: "Select this token"
        // TODO: onClicked
      }
      AVMEButton {
        id: btnRemove
        width: tokensPanel.width * 0.25
        enabled: (tokenGrid.currentItem && tokenGrid.currentItem.itemSymbol != "AVME")
        text: "Remove this token"
        onClicked: removeTokenPopup.open()
      }
    }
  }

  // Popup for adding a new token
  AVMEPopupYesNo {
    id: addTokenPopup
    property bool addFail: false
    height: window.height * 0.35
    info: (!addFail)
    ? "Enter the new token's address."
    : "Token not found or couldn't be added,<br>please try another or check the formatting."
    yesBtn.text: "Add"
    noBtn.text: "Back"
    yesBtn.enabled: (tokenAddressInput.acceptableInput)

    AVMEInput {
      id: tokenAddressInput
      width: parent.width * 0.9
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
      label: "Token address"
      placeholder: "e.g. 0x123456789ABCDEF..."
    }

    yesBtn.onClicked: {
      if (System.addTokenToList(tokenAddressInput.text)) {
        addFail = false
        reloadTokenList()
        tokenAddressInput.text = ""
        addTokenPopup.close()
      } else {
        addFail = true
      }
    }
    noBtn.onClicked: {
      tokenAddressInput.text = ""
      addFail = false
      addTokenPopup.close()
    }
  }

  // Popup for removing a token
  AVMEPopupYesNo {
    id: removeTokenPopup
    height: window.height * 0.35
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to remove this token from the list?"
    + "<br>Your balance will remain intact, but you'll have to"
    + "<br>add the token again to access it."
    yesBtn.onClicked: {
      if (System.removeTokenFromList(tokenGrid.currentItem.itemAddress)) {
        reloadTokenList()
      }
      removeTokenPopup.close()
    }
    noBtn.onClicked: {
      removeTokenPopup.close()
    }
  }
}
