/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's addresses and amounts.
 * Requires a ListModel with the following items:
 * - "account": the account's actual address
 * - "name": the account's name/label
 * - "coinAmount": the account's amount in <coin-name>
 */
ListView {
  id: walletList
  property color listHighlightColor: "#887AC1EB"
  property color listBgColor: "#58A0C9"
  property color listHoverColor: "#7AC1DB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  implicitWidth: 500
  implicitHeight: 500
  highlightMoveDuration: 0
  highlightMoveVelocity: 100000
  highlightResizeDuration: 0
  highlightResizeVelocity: 100000
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds

  // Header (top bar)
  header: Rectangle {
    id: listHeader
    width: parent.width
    height: 30
    radius: 5
    z: 2
    anchors.horizontalCenter: parent.horizontalCenter
    color: listBgColor

    Text {
      id: headerAccount
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 3
      color: "white"
      padding: 5
      text: "Account"
      font.pixelSize: 14.0
    }
    Text {
      id: headerName
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 3
      x: headerAccount.x + headerAccount.width
      color: "white"
      padding: 5
      text: "Name"
      font.pixelSize: 14.0
    }
    Text {
      id: headerCoinBalance
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 3
      x: headerName.x + headerName.width
      color: "white"
      padding: 5
      text: "AVAX Balance"
      font.pixelSize: 14.0
    }
  }
  headerPositioning: ListView.OverlayHeader // Prevent header scrolling along

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemAccount: account
      readonly property string itemName: name
      readonly property string itemCoinAmount: coinAmount
      width: parent.width
      height: 30

      Text {
        id: delegateAccount
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 3
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemAccount
        font.pixelSize: 14.0
      }
      Text {
        id: delegateName
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 3
        x: delegateAccount.x + delegateAccount.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemName
        font.pixelSize: 14.0
      }
      Text {
        id: delegateCoinBalance
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 3
        x: delegateName.x + delegateName.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: (itemCoinAmount) ? itemCoinAmount : "Loading..."
        font.pixelSize: 14.0
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: walletList.currentIndex = index
      }
    }
  }
}
