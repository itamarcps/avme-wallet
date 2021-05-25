/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Starting screen (for managing Wallets)

Item {
  id: startScreen
  property bool isCreate
  property bool isLoad
  property bool createWalletExists
  property bool loadWalletExists

  Connections {
    target: System
    function onAccountCreated(address) {
      System.setCurrentAccount(address)
      System.setDefaultCoin()
      System.setDefaultToken()
      walletNewPopup.close()
      System.goToOverview()
      System.setScreen(content, "qml/screens/OverviewScreen.qml")
    }
    function onAccountCreationFailed() {
      walletFailPopup.info = error.toString()
      walletFailPopup.open()
    }
  }

  // Header (logo + text)
  Image {
    id: logo
    width: 150
    height: 150
    anchors {
      top: parent.top
      left: parent.left
      topMargin: 20
      leftMargin: 50
    }
    antialiasing: true
    smooth: true
    source: "qrc:/img/avme_logo_hd.png"
    fillMode: Image.PreserveAspectFit

    Text {
      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.right
        leftMargin: 20
      }
      font.bold: true
      color: "#FFFFFF"
      font.pixelSize: 36.0
      text: {
        if (isCreate) {
          text: "Create/Import Wallet"
        } else if (isLoad) {
          text: "Load Wallet"
        } else {
          text: "Welcome to the AVME Wallet"
        }
      }
    }
  }

  // Starting rectangle
  Rectangle {
    id: startRect
    width: parent.width * 0.4
    height: 150
    visible: (!isCreate && !isLoad)
    anchors {
      top: logo.bottom
      left: parent.left
      topMargin: 20
      leftMargin: 50
    }
    color: "#2D3542"
    radius: 10

    AVMEButton {
      id: btnStartCreate
      width: parent.width * 0.9
      anchors {
        centerIn: parent
        verticalCenterOffset: -30
      }
      text: "Create/Import Wallet"
      onClicked: isCreate = true
    }

    AVMEButton {
      id: btnStartLoad
      width: parent.width * 0.9
      anchors {
        centerIn: parent
        verticalCenterOffset: 30
      }
      text: "Load Wallet"
      onClicked: isLoad = true
    }
  }

  // Create/Import rectangle
  Rectangle {
    id: createRect
    width: parent.width * 0.4
    height: 420
    visible: isCreate
    anchors {
      top: logo.bottom
      left: parent.left
      topMargin: 20
      leftMargin: 50
    }
    color: "#2D3542"
    radius: 10

    Column {
      id: createItems
      anchors.fill: parent
      spacing: 30
      topPadding: 30

      // Create Wallet folder
      Row {
        id: createFolderRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: createFolderInput
          width: (createItems.width * 0.9) - (createFolderDialogBtn.width + parent.spacing)
          readOnly: true
          label: "Wallet folder"
          placeholder: "Your Wallet's top folder"
          Component.onCompleted: {
            createFolderInput.text = System.getDefaultWalletPath()
            createWalletExists = System.checkFolderForWallet(createFolderInput.text)
          }
        }
        AVMEButton {
          id: createFolderDialogBtn
          width: (createItems.width * 0.1)
          height: createFolderInput.height
          text: ""
          onClicked: createFolderDialog.visible = true
          Image {
            anchors.fill: parent
            anchors.margins: 10
            source: "qrc:/img/icons/folder.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
          }
        }
        FolderDialog {
          id: createFolderDialog
          title: "Choose your Wallet folder"
          onAccepted: {
            createFolderInput.text = System.cleanPath(createFolderDialog.folder)
            createWalletExists = System.checkFolderForWallet(createFolderInput.text)
          }
        }
      }

      // Passphrase + view button
      Row {
        id: createPassRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: createPassInput
          width: (createItems.width * 0.9) - (createPassViewBtn.width + parent.spacing)
          echoMode: (createPassViewBtn.view) ? TextInput.Normal : TextInput.Password
          passwordCharacter: "*"
          label: "Passphrase"
          placeholder: "Your Wallet's passphrase"
        }
        AVMEButton {
          id: createPassViewBtn
          property bool view: false
          width: (createItems.width * 0.1)
          height: createPassInput.height
          text: ""
          onClicked: view = !view
          Image {
            anchors.fill: parent
            anchors.margins: 10
            source: (parent.view) ? "qrc:/img/icons/eye-f.png" : "qrc:/img/icons/eye-close-f.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
          }
        }
      }

      // Confirm passphrase + check icon
      Row {
        id: createPassCheckRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: createPassCheckInput
          width: (createItems.width * 0.9) - (createPassCheckIcon.width + parent.spacing)
          echoMode: (createPassViewBtn.view) ? TextInput.Normal : TextInput.Password
          passwordCharacter: "*"
          label: "Confirm passphrase"
          placeholder: "Your Wallet's passphrase"
        }

        Image {
          id: createPassCheckIcon
          width: (createItems.width * 0.1)
          height: createPassCheckInput.height
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
          source: {
            if (createPassInput.text == "" || createPassCheckInput.text == "") {
              source: ""
            } else if (createPassInput.text == createPassCheckInput.text) {
              source: "qrc:/img/ok.png"
            } else {
              source: "qrc:/img/no.png"
            }
          }
        }
      }

      // Optional seed (Import)
      Text {
        id: createSeedText
        color: "#FFFFFF"
        font.pixelSize: 14.0
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Importing an existing Wallet?"
      }

      AVMEInput {
        id: createSeedInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: (createItems.width * 0.9)
        label: "(Optional) Seed"
        placeholder: "Your 12-word seed phrase"
      }

      // Buttons for Create/Import Wallet
      Row {
        id: btnCreateRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        AVMEButton {
          id: btnCreateBack
          width: (createItems.width * 0.4)
          text: "Back"
          onClicked: isCreate = false
        }

        AVMEButton {
          id: btnCreate
          width: (createItems.width * 0.4)
          enabled: (
            createFolderInput.text != "" && createPassInput.text != ""
            && createPassCheckInput.text != "" && !createWalletExists
            && createPassInput.text == createPassCheckInput.text
          )
          text: {
            if (createWalletExists) {
              text: "Wallet exists"
            } else if (!createWalletExists && createSeedInput.text == "") {
              text: "Create Wallet"
            } else if (!createWalletExists && createSeedInput.text != "") {
              text: "Import Wallet"
            }
          }
          onClicked: {
            try {
              if (createPassInput.text != createPassCheckInput.text) {
                throw "Passphrases don't match. Please check your inputs."
              } else if (!createWalletExists && createSeedInput.text == "") {
                if (!System.createWallet(createFolderInput.text, createPassInput.text)) {
                  throw "Error on Wallet creation. Please check"
                  + "<br>the folder path and/or passphrase."
                }
                console.log("Wallet created successfully, now loading it...")
              } else if (!createWalletExists && createSeedInput.text != "") {
                if (!System.seedIsValid(createSeedInput.text)) {
                  throw "Error on Wallet importing. Seed is invalid,"
                  + "<br>please check the spelling and/or formatting."
                } else if (!System.importWallet(createSeedInput.text, createFolderInput.text, createPassInput.text)) {
                  throw "Error on Wallet importing. Please check"
                  + "<br>the folder path and/or passphrase.";
                }
                console.log("Wallet imported successfully, now loading it...")
              }
              if (System.isWalletLoaded()) { System.closeWallet() }
              if (!System.loadWallet(createFolderInput.text, createPassInput.text)) {
                throw "Error on Wallet loading. Please check"
                + "<br>the folder path and/or passphrase.";
              }
              console.log("Wallet loaded successfully")
              newWalletSeedPopup.newWalletPass = createPassInput.text
              newWalletSeedPopup.showSeed()
              newWalletSeedPopup.open()
            } catch (error) {
              walletFailPopup.info = error.toString()
              walletFailPopup.open()
            }
          }
        }
      }
    }
  }

  // Load rectangle
  Rectangle {
    id: loadRect
    width: parent.width * 0.4
    height: 230
    visible: isLoad
    anchors {
      top: logo.bottom
      left: parent.left
      topMargin: 20
      leftMargin: 50
    }
    color: "#2D3542"
    radius: 10

    Column {
      id: loadItems
      anchors.fill: parent
      spacing: 30
      topPadding: 30

      // Load Wallet folder
      Row {
        id: loadFolderRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: loadFolderInput
          width: (loadItems.width * 0.9) - (loadFolderDialogBtn.width + parent.spacing)
          readOnly: true
          label: "Wallet folder"
          placeholder: "Your Wallet's top folder"
          Component.onCompleted: {
            loadFolderInput.text = System.getDefaultWalletPath()
            loadWalletExists = System.checkFolderForWallet(loadFolderInput.text)
          }
        }
        AVMEButton {
          id: loadFolderDialogBtn
          width: 40
          height: loadFolderInput.height
          text: ""
          onClicked: loadFolderDialog.visible = true
          Image {
            anchors.fill: parent
            anchors.margins: 10
            source: "qrc:/img/icons/folder.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
          }
        }
        FolderDialog {
          id: loadFolderDialog
          title: "Choose your Wallet folder"
          onAccepted: {
            loadFolderInput.text = System.cleanPath(loadFolderDialog.folder)
            loadWalletExists = System.checkFolderForWallet(loadFolderInput.text)
          }
        }
      }

      // Passphrase
      AVMEInput {
        id: loadPassInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: (loadItems.width * 0.9)
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Your Wallet's passphrase"
      }

      // Buttons for Load Wallet
      Row {
        id: btnLoadRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        AVMEButton {
          id: btnLoadBack
          width: (loadItems.width * 0.4)
          text: "Back"
          onClicked: isLoad = false
        }

        AVMEButton {
          id: btnLoad
          width: (loadItems.width * 0.4)
          enabled: (loadFolderInput.text != "" && loadPassInput.text != "" && loadWalletExists)
          text: (loadWalletExists) ? "Load Wallet" : "No Wallet found"
          onClicked: {
            try {
              if (System.isWalletLoaded()) { System.closeWallet() }
              if (!System.loadWallet(loadFolderInput.text, loadPassInput.text)) {
                throw "Error on Wallet loading. Please check"
                + "<br>the folder path and/or passphrase.";
              }
              console.log("Wallet loaded successfully")
              System.setScreen(content, "qml/screens/AccountsScreen.qml")
            } catch (error) {
              walletFailPopup.info = error.toString()
              walletFailPopup.open()
            }
          }
        }
      }
    }
  }

  // Info popup for if the Wallet creation/loading/importing fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
  }

  // Popup for viewing the seed at Wallet creation
  AVMEPopupNewWalletSeed {
    id: newWalletSeedPopup
    okBtn.onClicked: {
      System.createAccount(newWalletSeed, 0, "", newWalletPass)
      newWalletSeedPopup.clean()
      newWalletSeedPopup.close()
      walletNewPopup.open()
    }
  }

  // Popup for waiting while the first Account is created for a new Wallet
  AVMEPopup {
    id: walletNewPopup
    property string pass
    info: "Creating an Account<br>for the new Wallet..."
  }
}
