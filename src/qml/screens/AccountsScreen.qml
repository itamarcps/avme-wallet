import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for listing Accounts and their general operations

Item {
  id: accountsScreen

  Connections {
    target: System

    onAccountCreated: {
      console.log("Account created successfully")
      createAccountPopup.close()
      reloadList()
    }
    onAccountCreationFailed: {
      console.log("Failed to create Account")
      createAccountPopup.close()
      accountFailPopup.open()
    }
  }

  Component.onCompleted: {
    // Always default to AVAX & AVME on first load
    if (System.getCurrentCoin() == "") {
      System.setCurrentCoin("AVAX")
      System.setCurrentCoinDecimals(18)
    }
    if (System.getCurrentToken() == "") {
      System.setCurrentToken("AVME")
      System.setCurrentTokenDecimals(18)
    }
    if (System.getFirstLoad()) {
      System.setFirstLoad(false)
      reloadList()
    }
  }

  // Timer for reloading the Account balances on the list
  Timer {
    id: listReloadTimer
    interval: 1000
    repeat: true
    onTriggered: reloadBalances()
  }

  // Helpers for manipulating the Account list
  function reloadList() {
    console.log("Reloading list...")
    fetchAccountsPopup.open()
    System.stopAllBalanceThreads()
    listReloadTimer.stop()
    accountsList.clear()
    System.loadAccounts()
    var accList = System.listAccounts()
    for (var i = 0; i < accList.length; i++) {
      var acc = JSON.parse(accList[i])
      accountsList.append(acc)
      System.startBalanceThread(acc.account)
    }
    listReloadTimer.start()
    fetchAccountsPopup.close()
  }

  function reloadBalances() {
    var accList = System.listAccounts()
    for (var i = 0; i < accList.length; i++) {
      accountsList.set(i, JSON.parse(accList[i]))
    }
  }

  // Background icon
  Image {
    id: bgIcon
    width: 256
    height: 256
    anchors.centerIn: parent
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/avme_logo.png"
  }

  // Top buttons (Account management)
  Row {
    id: btnTopRow
    spacing: 10
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 10
      leftMargin: 10
    }

    AVMEButton {
      id: btnEraseAccount
      width: (parent.width / 3) - parent.spacing
      enabled: (walletList.currentItem)
      text: "Erase Account"
      onClicked: {
        erasePopup.account = walletList.currentItem.itemAccount
        erasePopup.open()
      }
    }
    AVMEButton {
      id: btnUseAccount
      width: (parent.width / 3) - parent.spacing
      enabled: (walletList.currentItem)
      text: "Use this Account"
      onClicked: {
        System.setTxSenderAccount(walletList.currentItem.itemAccount)
        listReloadTimer.stop()
        System.setScreen(content, "qml/screens/StatsScreen.qml")
      }
    }
    AVMEButton {
      id: btnNewAccount
      width: (parent.width / 3) - parent.spacing
      text: "Create/Import Account"
      onClicked: chooseAccountPopup.open()
    }
  }

  // Account list
  Rectangle {
    id: listRect
    anchors {
      top: btnTopRow.bottom
      bottom: btnBottomRow.top
      left: parent.left
      right: parent.right
      margins: 10
    }
    radius: 5
    color: "#4458A0C9"

    // TODO: add fiat pricing here too when the time comes
    AVMEWalletList {
      id: walletList
      width: listRect.width
      height: listRect.height
      model: ListModel { id: accountsList }
    }
  }

  // Bottom buttons (actions)
  Row {
    id: btnBottomRow
    spacing: 10
    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      bottomMargin: 10
      leftMargin: 10
    }

    AVMEButton {
      id: btnCloseWallet
      width: (parent.width / 3) - parent.spacing
      text: "Close Wallet"
      onClicked: closeWalletPopup.open()
    }
    AVMEButton {
      id: btnCopyAddress
      width: (parent.width / 3) - parent.spacing
      Timer { id: textTimer; interval: 2000 }
      enabled: (walletList.currentItem && !textTimer.running)
      text: (!textTimer.running) ? "Copy Address to Clipboard" : "Copied!"
      onClicked: {
        System.copyToClipboard(walletList.currentItem.itemAccount)
        textTimer.start()
      }
    }
    AVMEButton {
      id: btnViewSeed
      width: (parent.width / 3) - parent.spacing
      text: "View Wallet Seed"
      onClicked: viewSeedPopup.open()
    }
  }

  // Popup for choosing an Account from a generated list
  AVMEPopupChooseAccount {
    id: chooseAccountPopup
    chooseBtn.onClicked: {
      if (System.accountExists(item.itemAccount)) {
        addressTimer.start()
      } else if (!System.checkWalletPass(pass)) {
        infoTimer.start()
      } else {
        try {
          System.stopAllBalanceThreads()
          listReloadTimer.stop()
          chooseAccountPopup.close()
          console.log(((foreignSeed != "") ? "Importing" : "Creating") + " Account...")
          System.createAccount(foreignSeed, index, name, pass)
          chooseAccountPopup.clean()
          createAccountPopup.open()
        } catch (error) {
          chooseAccountPopup.close()
          accountFailPopup.open()
        }
      }
    }
  }

  // Popup for viewing the Wallet's seed
  AVMEPopupViewSeed {
    id: viewSeedPopup
    showBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        viewSeedPopup.showSeed()
      } else {
        viewSeedPopup.showErrorMsg()
      }
    }
  }

  // Popup for fetching Accounts
  AVMEPopup {
    id: fetchAccountsPopup
    info: "Loading Accounts...<br>Please wait."
  }

  // Popup for waiting for a new Account to be created
  AVMEPopup {
    id: createAccountPopup
    info: "Creating/Importing Account..."
  }

  // Info popup for if the Account creation fails
  AVMEPopupInfo {
    id: accountFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on Account creation/importing. Please try again."
  }

  // Info popup for if the Account erasure fails
  AVMEPopupInfo {
    id: eraseFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on erasing Account. Please try again."
  }

  // Yes/No popup for confirming Wallet closure
  AVMEPopupYesNo {
    id: closeWalletPopup
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to close this Wallet?"
    yesBtn.onClicked: {
      closeWalletPopup.close()
      console.log("Wallet closed successfully")
      System.stopAllBalanceThreads()
      listReloadTimer.stop()
      System.closeWallet()
      System.setScreen(content, "qml/screens/StartScreen.qml")
    }
    noBtn.onClicked: closeWalletPopup.close()
  }

  // Yes/No popup for confirming Account erasure
  AVMEPopupYesNo {
    id: erasePopup
    property string account
    height: window.height / 2
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to erase this Account?<br>"
    + "<b>" + account + "</b>"
    + "<br>All funds on it will be <b>PERMANENTLY LOST</b>."

    Text {
      id: erasePassInfo
      property alias timer: erasePassInfoTimer
      y: (parent.height / 2) - 30
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottomMargin: (parent.height / 2) + 50
      Timer { id: erasePassInfoTimer; interval: 2000 }
      text: (!erasePassInfoTimer.running)
      ? "Please authenticate to confirm the action."
      : "Wrong passphrase, please try again"
    }

    AVMEInput {
      id: erasePassInput
      width: parent.width / 2
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: erasePassInfo.bottom
      anchors.topMargin: 30
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    yesBtn.onClicked: {
      if (System.checkWalletPass(erasePassInput.text)) {
        if (System.eraseAccount(walletList.currentItem.itemAccount)) {
          System.stopAllBalanceThreads()
          listReloadTimer.stop()
          console.log("Account erased successfully")
          erasePopup.close()
          erasePopup.account = ""
          erasePassInput.text = ""
          reloadList()
        } else {
          erasePopup.close()
          erasePopup.account = ""
          erasePassInput.text = ""
          eraseFailPopup.open()
        }
      } else {
        erasePassInfoTimer.start()
      }
    }
    noBtn.onClicked: {
      erasePopup.account = ""
      erasePassInput.text = ""
      erasePopup.close()
    }
  }
}

