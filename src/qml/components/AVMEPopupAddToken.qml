/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Popup for adding a new token to the Wallet.
Popup {
  id: addTokenPopup
  property bool tokenFound: false
  property bool tokenDataFound: false
  property color popupBgColor: "#1C2029"

  function clean() {
    tokenFound = tokenDataFound = false
    tokenAddressInput.text = tokenSymbolInput.text = tokenDecimalsInput.text = ""
  }

  width: (parent.width * 0.5)
  height: (parent.height * 0.4)
  x: (parent.width * 0.5) - (width / 2)
  y: (parent.height * 0.5) - (height / 2)
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }

  Text {
    id: info
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      topMargin: 20
    }
    horizontalAlignment: Text.AlignHCenter
    color: "#FFFFFF"
    font.pixelSize: 14.0
    Timer { id: notFoundTimer; interval: 2000 }
    Timer { id: existsTimer; interval: 2000 }
    Timer { id: addFailTimer; interval: 2000 }
    text: {
      if (tokenFound && tokenDataFound) {
        text: "Token found! Please confirm the details."
      } else if (tokenFound && !tokenDataFound) {
        text: "Token found but missing details, please enter them manually."
      } else if (existsTimer.running) {
        text: "Token was already added, please try another."
      } else if (notFoundTimer.running) {
        text: "Token not found, please check your input or try another."
      } else if (addFailTimer.running) {
        text: "Failed to add token, please try again."
      } else {
        text: "Enter the new token's address."
      }
    }
  }

  Column {
    id: inputCol
    anchors {
      top: info.bottom
      bottom: btnRow.top
      left: parent.left
      right: parent.right
      margins: 40
    }
    spacing: 40

    AVMEInput {
      id: tokenAddressInput
      width: parent.width
      readOnly: (tokenFound)
      anchors.horizontalCenter: parent.horizontalCenter
      validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
      label: "Token address"
      placeholder: "e.g. 0x123456789ABCDEF..."
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: tokenSymbolInput
        width: inputCol.width * 0.4
        readOnly: (tokenDataFound)
        visible: (tokenFound)
        label: "Token symbol"
      }

      AVMEInput {
        id: tokenDecimalsInput
        width: inputCol.width * 0.4
        readOnly: (tokenDataFound)
        visible: (tokenFound)
        validator: RegExpValidator { regExp: /[0-9]{1,}/ }
        label: "Token decimals"
      }
    }
  }

  Row {
    id: btnRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
    spacing: 10

    AVMEButton {
      id: btnClose
      width: addTokenPopup.width * 0.4
      text: "Close"
      onClicked: {
        addTokenPopup.clean()
        addTokenPopup.close()
      }
    }
    AVMEButton {
      id: btnAdd
      width: addTokenPopup.width * 0.4
      text: (tokenFound) ? "Add token" : "Search for token"
      enabled: tokenAddressInput.acceptableInput
      onClicked: {
        if (System.tokenIsAdded(tokenAddressInput.text)) {
          existsTimer.start()
        } else if (tokenFound) {
          if (System.addTokenToList(tokenAddressInput.text)) {
            reloadTokenList() // Parent call
            addTokenPopup.clean()
            addTokenPopup.close()
          } else {
            addFailTimer.start()
          }
        } else if (!tokenFound) {
          if (System.isERC20Token(tokenAddressInput.text)){
            tokenFound = true
            var tokenData = System.getERC20TokenData(tokenAddressInput.text);
            if (tokenData && tokenData.symbol != "") {
              tokenDataFound = true
              tokenSymbolInput.text = tokenData.symbol
              tokenDecimalsInput.text = tokenData.decimals
            } else {
              tokenDataFound = false
            }
          } else {
            notFoundTimer.start()
          }
        }
      }
    }
  }
}
