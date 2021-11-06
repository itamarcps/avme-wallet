/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import QmlApi 1.0

import "qrc:/qml/components"
import "qrc:/qml/popups"

// The main window
ApplicationWindow {
  id: window
  property alias infoPopup: infoPopup
  property alias menu: sideMenu

  QmlApi { id: qmlApi }

  title: "AVME Wallet " + qmlSystem.getProjectVersion()
  width: 1280
  height: 720
  minimumWidth: 1280
  minimumHeight: 720
  visible: true

  Connections {
    target: qmlSystem
      function onWalletRequireUpdate() {
        walletRequireUpdate.open()
      }
  }

  function startup() {
    qmlSystem.checkWalletVersion()
    var lastPath = qmlSystem.getLastWalletPath()
    var defaultPath = qmlSystem.defaultWalletPathExists()
    var screen = (lastPath != "" || defaultPath) ? "LoadWallet" : "CreateWallet"
    menu.changeScreen(screen)
  }

  Component.onCompleted: menuTimer.start()

  // Timer for preventing side menu items from getting all squashed
  Timer { id: menuTimer; interval: 100; onTriggered: startup() }

  Rectangle {
    id: bg
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#0F0C18" }
      GradientStop { position: 1.0; color: "#190B25" }
    }
    AVMEAsyncImage {
      id: logoBg
      width: 1000
      height: 1000
      loading: false
      anchors { right: parent.right; bottom: parent.bottom; margins: -300 }
      imageOpacity: 0.15
      imageSource: "qrc:/img/avme_logo.png"
    }
  }

  AVMESideMenu {
    id: sideMenu
    anchors { top: parent.top; left: parent.left; bottom: parent.bottom }
  }

  AVMEAccountHeader {
    id: accountHeader
    anchors { top: parent.top; topMargin: 10; horizontalCenter: content.horizontalCenter }
  }

  AVMEPopup {
    id: infoPopup
    property alias info: infoText.text
    x: ((parent.width / 2) - (width / 2)) + (sideMenu.width / 2)  // Override
    widthPct: 0.2
    heightPct: 0.1
    onAboutToHide: info = ""
    Text {
      id: infoText
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
    }
  }

  AVMEPopupInfo {
    id: walletRequireUpdate
    widthPct: 0.4
    heightPct: 0.3
    icon: "qrc:/img/warn.png"
    info: "Please update your wallet to the latest version."
    okBtn.text: "Close"
  }


  // Dynamic screen loader (used in setScreen(id, screenpath))
  Loader {
    id: content
    anchors {
      top: accountHeader.bottom
      bottom: parent.bottom
      left: sideMenu.right
      right: parent.right
    }
    antialiasing: true
    smooth: true
  }
}
