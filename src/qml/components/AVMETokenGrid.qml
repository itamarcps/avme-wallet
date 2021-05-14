/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom grid view for managing tokens.
 * Requires a ListModel with the following items:
 * - "image": the token's icon
 * - "label": the token's symbol
 */
GridView {
  id: tokenGrid
  property color listHighlightColor: "#887AC1EB"
  property color listHoveredColor: "#447AC1EB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  implicitWidth: 500
  implicitHeight: 500
  highlightMoveDuration: 0
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  cellWidth: 120
  cellHeight: 120

  delegate: Component {
    id: gridDelegate
    Item {
      id: gridItem
      readonly property string itemAddress: address
      readonly property string itemSymbol: symbol
      readonly property int itemDecimals: decimals
      readonly property string itemImage: image
      width: tokenGrid.cellWidth - 10
      height: tokenGrid.cellHeight - 10
      Rectangle { id: gridItemBg; anchors.fill: parent; radius: 5; color: "transparent" }
      Column {
        anchors.centerIn: parent
        spacing: 10
        Image {
          width: 64
          height: 64
          antialiasing: true
          smooth: true
          source: itemImage
          anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
          color: "#FFFFFF"
          font.pixelSize: 18.0
          text: itemSymbol
          anchors.horizontalCenter: parent.horizontalCenter
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: gridItemBg.color = listHoveredColor
        onExited: gridItemBg.color = "transparent"
        onClicked: tokenGrid.currentIndex = index
      }
    }
  }
}
