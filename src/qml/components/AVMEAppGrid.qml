/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// GridView for installed DApps.
GridView {
  id: appGrid
  property color listHighlightColor: "#887AC1EB"
  property color listHoveredColor: "#447AC1EB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  highlightMoveDuration: 0
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  cellWidth: 140
  cellHeight: 140

  Component.onCompleted: forceActiveFocus()

  // Enter/Numpad enter key override
  Keys.onPressed: {
    if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
      if (currentIndex != -1) {
        qmlSystem.setScreen(content, "qml/screens/AppScreen.qml")
        qmlSystem.appLoaded(qmlSystem.getAppFolderPath(
          appsPanel.selectedApp.itemChainId, appsPanel.selectedApp.itemFolder
        ))
      }
    }
  }

  delegate: Component {
    id: gridDelegate
    Item {
      id: gridItem
      readonly property string itemChainId: chainId
      readonly property string itemFolder: folder
      readonly property string itemName: name
      readonly property int itemMajor: major
      readonly property int itemMinor: minor
      readonly property int itemPatch: patch
      readonly property bool itemIsUpdated: isUpdated
      readonly property int itemNextMajor: nextMajor
      readonly property int itemNextMinor: nextMinor
      readonly property int itemNextPatch: nextPatch
      width: appGrid.cellWidth - 10
      height: appGrid.cellHeight - 10
      Rectangle { id: gridItemBg; anchors.fill: parent; radius: 5; color: "transparent" }

      Rectangle {
        id: appUpdateStatus
        width: 16
        height: 16
        visible: !itemIsUpdated
        anchors.top: parent.top
        anchors.right: parent.right
        radius: width * 0.5
        color: "yellow"
      }

      Column {
        anchors.centerIn: parent
        spacing: 10
        AVMEAsyncImage {
          id: appImage
          property var imgUrl: "https://raw.githubusercontent.com"
            + "/avme/avme-wallet-applications/main/apps/"
            + itemChainId + "/" + itemFolder + "/icon.png"
          width: 96
          height: 96
          anchors.horizontalCenter: parent.horizontalCenter
          Component.onCompleted: { qmlSystem.checkIfUrlExists(Qt.resolvedUrl(imgUrl)) }
          Connections {
            target: qmlSystem
            function onUrlChecked(link, b) {
              if (link == appImage.imgUrl) {
                appImage.imageSource = (b)
                  ? appImage.imgUrl : "qrc:/img/unknown_token.png"
              }
            }
          }
        }
        Text {
          id: appName
          width: gridItem.width * 0.9
          height: gridItem.height - appImage.height - parent.spacing
          anchors.horizontalCenter: parent.horizontalCenter
          color: "#FFFFFF"
          font.pixelSize: 12.0
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          wrapMode: Text.WordWrap
          text: itemName
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: gridItemBg.color = listHoveredColor
        onExited: gridItemBg.color = "transparent"
        onClicked: {
          appGrid.currentIndex = index
          forceActiveFocus()
        }
        onDoubleClicked: {
          qmlSystem.setScreen(content, "qml/screens/AppScreen.qml")
          qmlSystem.appLoaded(qmlSystem.getAppFolderPath(
            appsPanel.selectedApp.itemChainId, appsPanel.selectedApp.itemFolder
          ))
        }
      }
    }
  }
}
