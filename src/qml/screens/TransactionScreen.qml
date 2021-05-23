/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Screen for sending/receiving transactions. Supported operations are:
 * "Send AVAX", "Send AVME",
 * "Approve Exchange", "Approve Liquidity", "Approve Staking",
 * "Swap AVAX -> AVME", "Swap AVME -> AVAX",
 * "Add Liquidity", "Remove Liquidity",
 * "Stake LP", "Unstake LP", "Harvest AVME", "Exit Staking"
 */

/**
 * TODO: There needs to be some refactor on the part of calculating
 * transaction costs, currently it is working but for good pratices and
 * capabilities of maintaining the code, refactor it before editing anything.
 */
Item {
  id: transactionScreen
  property string txOperationStr
  property string txTotalCoinStr
  property string txTotalTokenStr
  property string txTotalLPStr

  Connections {
    target: System
    function onOperationOverride(op, amountCoin, amountToken, amountLP) {
      changeOperation(op)
      txAmountCoinInput.text = amountCoin
      txAmountTokenInput.text = amountToken
      txAmountLPInput.text = amountLP
      txAmountCoinInput.enabled = false
      txAmountTokenInput.enabled = false
      txAmountLPInput.enabled = false
      autoLimitCheck.visible = false
      autoGasCheck.visible = false
      updateTxCost()
      switch (op) {
        case "Swap AVME -> AVAX":
          txTotalCoinStr = System.calculateTransactionCost(
            "0", txGasLimitInput.text, txGasPriceInput.text
          )
          break;
      }
    }
  }

  function updateTxCost() {
    txTotalCoinStr = System.calculateTransactionCost(
      txAmountCoinInput.text, txGasLimitInput.text, txGasPriceInput.text
    )
    txTotalTokenStr = System.calculateTransactionCost(
      txAmountTokenInput.text, "0", "0"
    )
    txTotalLPStr = System.calculateTransactionCost(
      txAmountLPInput.text, "0", "0"
    )
  }

  function checkTransactionFunds() {
    var acc = System.getAccountBalances(System.getCurrentAccount())
    var isFreeLP = (txOperationStr == "Remove Liquidity" || txOperationStr == "Stake LP")
    var hasCoinFunds = !System.hasInsufficientFunds(
      "Coin", acc.balanceAVAX, System.calculateTransactionCost(
        txTotalCoinStr.text, txGasLimitInput.text, txGasPriceInput.text
      )
    )
    var hasTokenFunds = !System.hasInsufficientFunds(
      "Token", acc.balanceAVME, txTotalTokenStr.text
    )
    var hasLPFunds = !System.hasInsufficientFunds(
      "LP", ((isFreeLP) ? acc.balanceLPFree : acc.balanceLPLocked), txTotalLPStr.text
    )
    switch (txOperationStr) {
      case "Send AVAX":
      case "Swap AVAX -> AVME":
      case "Approve Exchange":
      case "Approve Liquidity":
      case "Approve Staking":
      case "Harvest AVME":
      case "Exit Staking":
        return (hasCoinFunds);
        break;
      case "Send AVME":
      case "Swap AVME -> AVAX":
      case "Add Liquidity":
        return (hasCoinFunds && hasTokenFunds);
        break;
      case "Remove Liquidity":
      case "Stake LP":
      case "Unstake LP":
        return (hasCoinFunds && hasLPFunds);
        break;
    }
  }

  function changeOperation(op) {
    // Clean all inputs first, then set the gas limit and enable only the required inputs
    txToInput.text = txAmountCoinInput.text = txAmountTokenInput.text = txAmountLPInput.text = ""
    txOperationStr = op
    txToInput.visible = (op == "Send AVAX" || op == "Send AVME")
    autoLimitCheck.checked = autoGasCheck.checked = true
    if (op == "Send AVAX" || op == "Send AVME") {
      txGasLimitInput.text = "21000"
    } else if (op == "Swap AVAX -> AVME" || op == "Swap AVME -> AVAX") {
      txGasLimitInput.text = "180000"
    } else {
      txGasLimitInput.text = "250000"
    }
    txGasPriceInput.text = System.getAutomaticFee()
    updateTxCost()
    switch (op) {
      // AVAX only
      case "Send AVAX":
      case "Swap AVAX -> AVME":
        txAmountCoinInput.visible = true
        txAmountTokenInput.visible = false
        txAmountLPInput.visible = false
        break;
      // AVME only
      case "Send AVME":
      case "Swap AVME -> AVAX":
        txAmountCoinInput.visible = false
        txAmountTokenInput.visible = true
        txAmountLPInput.visible = false
        break;
      // AVAX + AVME
      case "Add Liquidity":
        txAmountCoinInput.visible = true
        txAmountTokenInput.visible = true
        txAmountLPInput.visible = false
        break;
      // LP only
      case "Remove Liquidity":
      case "Stake LP":
      case "Unstake LP":
        txAmountCoinInput.visible = false
        txAmountTokenInput.visible = false
        txAmountLPInput.visible = true
        break;
      // Nothing
      case "Approve Exchange":
      case "Approve Liquidity":
      case "Approve Staking":
      case "Harvest AVME":
      case "Exit Staking":
        txAmountCoinInput.visible = false
        txAmountTokenInput.visible = false
        txAmountLPInput.visible = false
        break;
    }
  }

  Component.onCompleted: {
    txGasPriceInput.text = System.getAutomaticFee()
    changeOperation("Send AVAX")
    updateTxCost()
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  // Panel for the transaction inputs
  AVMEPanel {
    id: txDetailsPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
    title: "Transaction Details"

    Column {
      id: txDetailsColumn
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 40

      Text {
        id: txOperation
        verticalAlignment: Text.AlignVCenter
        width: (parent.width * 0.6)
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Operation: <b>" + txOperationStr + "</b>"

        AVMEButton {
          id: btnChangeOp
          width: (txDetailsColumn.width * 0.4) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
          visible: (txOperationStr == "Send AVAX" || txOperationStr == "Send AVME")
          text: (txOperationStr == "Send AVAX")
          ? "Switch to " + System.getCurrentTokenName()
          : "Switch to " + System.getCurrentCoinName()
          onClicked: {
            if (txOperationStr == "Send AVAX") {
              changeOperation("Send AVME")
            } else if (txOperationStr == "Send AVME") {
              changeOperation("Send AVAX")
            }
          }
        }
      }

      AVMEInput {
        id: txFromInput
        anchors.left: parent.left
        width: parent.width
        readOnly: true
        label: "From"
        text: System.getCurrentAccount()
      }

      AVMEInput {
        id: txToInput
        width: txDetailsColumn.width
        validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
        label: "To"
        placeholder: "Receiver address - e.g. 0x123456789ABCDEF..."
      }

      AVMEInput {
        id: txAmountCoinInput
        width: (parent.width * 0.8)
        validator: RegExpValidator { regExp: System.createCoinRegExp() }
        label: System.getCurrentCoinName() + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: updateTxCost()

        AVMEButton {
          id: btnAmountCoinMax
          width: (txDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            txAmountCoinInput.text = System.getRealMaxAVAXAmount(
              txGasLimitInput.text, txGasPriceInput.text
            )
            updateTxCost()
          }
        }
      }

      AVMEInput {
        id: txAmountTokenInput
        width: (parent.width * 0.8)
        validator: RegExpValidator { regExp: System.createTokenRegExp() }
        label: System.getCurrentTokenName() + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: updateTxCost()

        AVMEButton {
          id: btnAmountTokenMax
          width: (txDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            var acc = System.getAccountBalances(System.getCurrentAccount())
            txAmountTokenInput.text = acc.balanceAVME
            updateTxCost()
          }
        }
      }

      AVMEInput {
        id: txAmountLPInput
        width: (parent.width * 0.8)
        validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
        label: "LP Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: updateTxCost()

        AVMEButton {
          id: btnAmountLPMax
          width: (txDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            // "Stake LP" = free LP, "Remove Liquidity" and "Unstake LP" = locked LP
            var acc = System.getAccountBalances(System.getCurrentAccount())
            txAmountLPInput.text = (txOperationStr == "Stake LP")
              ? acc.balanceLPFree : acc.balanceLPLocked
            updateTxCost()
          }
        }
      }

      Row {
        width: parent.width
        spacing: 10

        AVMEInput {
          id: txGasLimitInput
          width: (txDetailsColumn.width * 0.5)
          validator: RegExpValidator { regExp: /[0-9]+/ }
          label: "Gas Limit (in Wei)"
          enabled: !autoLimitCheck.checked
          onTextEdited: updateTxCost()
        }

        CheckBox {
          id: autoLimitCheck
          property string prev
          width: (txDetailsColumn.width * 0.5) - anchors.leftMargin
          checked: true
          enabled: true
          text: "Automatic Limit"
          font.pixelSize: 14.0
          contentItem: Text {
            text: parent.text
            font.pixelSize: 14.0
            color: parent.checked ? "#FFFFFF" : "#888888"
            verticalAlignment: Text.AlignVCenter
            leftPadding: parent.indicator.width + parent.spacing
          }
          onClicked: {
            if (!txGasLimitInput.enabled) { // Disabled field (auto limit on)
              txGasLimitInput.text = prev
            } else { // Enabled field (auto limit off)
              prev = txGasLimitInput.text
            }
            updateTxCost()
          }
        }
      }

      Row {
        width: parent.width
        spacing: 10

        AVMEInput {
          id: txGasPriceInput
          width: (txDetailsColumn.width * 0.5)
          validator: RegExpValidator { regExp: /[0-9]+/ }
          enabled: !autoGasCheck.checked
          label: "Gas Price (in Gwei)"
          onTextEdited: updateTxCost()
        }

        CheckBox {
          id: autoGasCheck
          property string prev
          width: (txDetailsColumn.width * 0.5) - anchors.leftMargin
          checked: true
          enabled: true
          text: "Recommended Fee"
          font.pixelSize: 14.0
          contentItem: Text {
            text: parent.text
            font.pixelSize: 14.0
            color: parent.checked ? "#FFFFFF" : "#888888"
            verticalAlignment: Text.AlignVCenter
            leftPadding: parent.indicator.width + parent.spacing
          }
          onClicked: {
            if (!txGasPriceInput.enabled) { // Disabled field (auto fee on)
              txGasPriceInput.text = prev
            } else {  // Enabled field (auto fee off)
              prev = txGasPriceInput.text
            }
            updateTxCost()
          }
        }
      }
    }
  }

  // Panel for the summary and auth
  AVMEPanel {
    id: txSummaryPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Transaction Summary"

    Column {
      id: txSummaryColumn
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 20

      Text {
        id: txSummaryOperationHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You will"
      }

      Text {
        id: txSummaryOperation
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        font.pixelSize: 24.0
        font.bold: true
        text: txOperationStr
      }

      Text {
        id: txSummaryOperationFooter
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: {
          switch (txOperationStr) {
            case "Send AVAX":
            case "Send AVME":
              text: "to the address<br><b>" + txToInput.text + "</b>"
              break;
            case "Approve Exchange":
              text: "(give approval to Pangolin to use your Account's"
              + "<br>currencies for swapping between each other)";
              break;
            case "Approve Liquidity":
              text: "(give approval to Pangolin to use your Account's"
              + "<br>currencies for managing pool liquidity)";
              break;
            case "Approve Staking":
              text: "(give approval to the staking contract to use your"
              + "<br>Account's currencies for staking/harvesting rewards)";
              break;
            case "Swap AVAX -> AVME":
            case "Swap AVME -> AVAX":
              text: "via Pangolin";
              break;
            case "Add Liquidity":
              text: "to the " + System.getCurrentCoinName() + "/" + System.getCurrentTokenName() + " pool";
              break;
            case "Remove Liquidity":
              text: "from the " + System.getCurrentCoinName() + "/" + System.getCurrentTokenName() + " pool";
              break;
            case "Stake LP":
              text: "in the staking contract";
              break;
            case "Unstake LP":
            case "Harvest AVME":
              text: "from the staking contract";
              break;
            case "Exit Staking":
              text: "(harvest all of the available reward and unstake"
              + "<br>all of the LP tokens from the staking contract)";
              break;
          }
        }
      }

      Text {
        id: txSummaryAmountsHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Amounts for the transaction:"
      }

      Text {
        id: txSummaryAmounts
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        font.bold: true
        font.pixelSize: 14.0
        color: "#FFFFFF"
        text: {
          switch (txOperationStr) {
            case "Send AVAX":
            case "Swap AVAX -> AVME":
              text: txAmountCoinInput.text + " " + System.getCurrentCoinName()
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitInput.text, 18)
              + " " + System.getCurrentCoinName()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceInput.text, 9)
              + " " + System.getCurrentCoinName();
              break;
            case "Send AVME":
            case "Swap AVME -> AVAX":
              text: txAmountTokenInput.text + " " + System.getCurrentTokenName()
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitInput.text, 18)
              + " " + System.getCurrentCoinName()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceInput.text, 9)
              + " " + System.getCurrentCoinName();
              break;
            case "Approve Exchange":
            case "Approve Liquidity":
            case "Approve Staking":
            case "Harvest AVME":
            case "Exit Staking":
              text: "Gas Limit: " + System.weiToFixedPoint(txGasLimitInput.text, 18)
              + " " + System.getCurrentCoinName()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceInput.text, 9)
              + " " + System.getCurrentCoinName();
              break;
            case "Add Liquidity":
              text: txAmountCoinInput.text + " " + System.getCurrentCoinName()
              + "<br>" + txAmountTokenInput.text + " " + System.getCurrentTokenName()
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitInput.text, 18)
              + " " + System.getCurrentCoinName()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceInput.text, 9)
              + " " + System.getCurrentCoinName();
              break;
            case "Remove Liquidity":
            case "Stake LP":
            case "Unstake LP":
              text: txAmountLPInput.text + " LP"
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitInput.text, 18)
              + " " + System.getCurrentCoinName()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceInput.text, 9)
              + " " + System.getCurrentCoinName();
              break;
          }
        }
      }

      Text {
        id: txTotalCostsHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Total cost to make the transaction:"
      }

      Text {
        id: txTotalCosts
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        font.bold: true
        font.pixelSize: 14.0
        color: "#FFFFFF"
        text: {
          switch (txOperationStr) {
            case "Send AVAX":
            case "Approve Exchange":
            case "Approve Liquidity":
            case "Approve Staking":
            case "Swap AVAX -> AVME":
            case "Harvest AVME":
            case "Exit Staking":
              text: txTotalCoinStr + " " + System.getCurrentCoinName();
              break;
            case "Send AVME":
            case "Swap AVME -> AVAX":
            case "Add Liquidity":
              text: txTotalCoinStr + " " + System.getCurrentCoinName()
              + "<br>" + txTotalTokenStr + " " + System.getCurrentTokenName();
              break;
            case "Remove Liquidity":
            case "Stake LP":
            case "Unstake LP":
              text: txTotalCoinStr + " " + System.getCurrentCoinName()
              + "<br>" + txTotalLPStr + " LP";
              break;
          }
        }
      }

      AVMEButton {
        id: btnMakeTx
        width: (txDetailsColumn.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Make Transaction"
        onClicked: {
          if (!checkTransactionFunds()) {
            fundsPopup.open()
          } else {
            confirmTxPopup.isSameAddress = (txFromInput.text === txToInput.text)
            confirmTxPopup.open()
          }
        }
      }
    }
  }

  // Popup for confirming transaction
  AVMEPopupConfirmTx {
    id: confirmTxPopup
    okBtn.onClicked: {
      if (!System.checkWalletPass(pass)) {
        timer.start()
      } else {
        confirmTxPopup.close()
        txProgressPopup.open()
        System.txStart(
          txOperationStr, txToInput.text,
          txAmountCoinInput.text, txAmountTokenInput.text, txAmountLPInput.text,
          txGasLimitInput.text, txGasPriceInput.text, pass
        )
        confirmTxPopup.clean()
      }
    }
  }

  // Popup for insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }

  // Popup for transaction progress
  AVMEPopupTxProgress {
    id: txProgressPopup
  }
}
