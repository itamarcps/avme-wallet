/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for exchanging coins/tokens in a given Account
Item {
  id: exchangeScreen
  property string allowance
  property string pairAddress
  property string inReserves
  property string outReserves
  property string swapEstimate
  property double swapImpact
  /*
  Connections {
    target: QmlSystem
    function onAllowancesUpdated(
      exchangeAllowance, liquidityAllowance, stakingAllowance
    ) {
      allowance = exchangeAllowance
      addAllowance = exchangeAllowance
      removeAllowance = liquidityAllowance
    }
    function onExchangeDataUpdated(
      lowerTokenName, lowerTokenReserves, higherTokenName, higherTokenReserves
    ) {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
    }
    function onLiquidityDataUpdated(
      lowerTokenName, lowerTokenReserves, higherTokenName, higherTokenReserves, totalLiquidity
    ) {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
      liquidity = totalLiquidity
      var userShares = QmlSystem.calculatePoolShares(
        lowerReserves, higherReserves, liquidity
      )
      userLowerReserves = userShares.lower
      userHigherReserves = userShares.higher
      userLPSharePercentage = userShares.liquidity
    }
  }

  Timer {
    id: reloadExchangeDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      QmlSystem.updateExchangeData("AVAX", "Token") // TODO: token name here
      calculateExchangeAmountOut()
    }
  }

  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      QmlSystem.updateLiquidityData("AVAX", "Token") // TODO: token name here
    }
  }

  // For manual input
  function calculateAddLiquidityAmount(fromCoin) {
    var amountIn = (fromCoin) ? liquidityCoinInput.text : liquidityTokenInput.text
    var amountName = (fromCoin) ? "AVAX" : "Token"  // TODO: token name here
    var maxAmountAVAX = QmlSystem.getRealMaxAVAXAmount("250000", QmlSystem.getAutomaticFee())
    var maxAmountAVME = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount()).balanceAVME
    var amountOut, coinAmount, tokenAmount

    // Set the values accordingly
    if (amountName == lowerToken) {
      amountOut = QmlSystem.calculateAddLiquidityAmount(amountIn, lowerReserves, higherReserves)
    } else if (amountName == higherToken) {
      amountOut = QmlSystem.calculateAddLiquidityAmount(amountIn, higherReserves, lowerReserves)
    }
    if (fromCoin) {
      liquidityTokenInput.text = amountOut
    } else {
      liquidityCoinInput.text = amountOut
    }
  }

  // For the Max Amounts button
  function calculateMaxAddLiquidityAmount() {
    var maxAmountAVAX = QmlSystem.getRealMaxAVAXAmount("250000", QmlSystem.getAutomaticFee())
    var maxAmountAVME = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount()).balanceAVME
    var coinAmount, tokenAmount

    // Get the expected amounts for maxed values
    if (lowerToken == "AVAX") {
      tokenAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVAX, lowerReserves, higherReserves)
      coinAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVME, higherReserves, lowerReserves)
    } else if (lowerToken == "Token") { // TODO: token name here
      coinAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVME, lowerReserves, higherReserves)
      tokenAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVAX, higherReserves, lowerReserves)
    }

    // Limit the max amount to the lowest the user has.
    // If coinAmount is higher than the user's AVAX balance,
    // then the AVAX user balance is limiting. Same with tokenAmount and AVME.
    if (QmlSystem.firstHigherThanSecond(coinAmount, maxAmountAVAX)) {
      maxAmountAVME = tokenAmount
    }
    if (QmlSystem.firstHigherThanSecond(tokenAmount, maxAmountAVME)) {
      maxAmountAVAX = coinAmount
    }

    // Set the values accordingly
    if (lowerToken == "AVAX") {
      liquidityCoinInput.text = maxAmountAVAX
      liquidityTokenInput.text = QmlSystem.calculateAddLiquidityAmount(
        maxAmountAVAX, lowerReserves, higherReserves
      )
    } else if (lowerToken == "Token") { // TODO: token name here
      liquidityTokenInput.text = maxAmountAVME
      liquidityCoinInput.text = QmlSystem.calculateAddLiquidityAmount(
        maxAmountAVME, lowerReserves, higherReserves
      )
    }
  }
  */

  Connections {
    target: accountHeader
    function onUpdatedBalances() { assetBalance.refresh() }
  }

  function fetchAllowance() {
    QmlApi.clearAPIRequests()
    QmlApi.buildGetAllowanceReq(
      fromAssetPopup.chosenAssetAddress,
      QmlSystem.getCurrentAccount(),
      QmlSystem.getContract("router")
    )
    QmlApi.buildGetPairReq(
      fromAssetPopup.chosenAssetAddress,
      toAssetPopup.chosenAssetAddress
    )
    var resp = JSON.parse(QmlApi.doAPIRequests())
    allowance = QmlApi.parseHex(resp[0].result, ["uint"])
    pairAddress = QmlApi.parseHex(resp[1].result, ["address"])
    // AVAX doesn't need approval, tokens do (and individually)
    if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
      exchangeDetailsColumn.visible = true
    } else {
      var asset = accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]
      exchangeDetailsColumn.visible = (+allowance >= +QmlSystem.fixedPointToWei(
        asset["balance"], fromAssetPopup.chosenAssetDecimals
      ))
      exchangeDetailsColumn.visible = true
    }
    assetBalance.refresh()
    refreshReserves()
  }

  function refreshReserves() {
    QmlApi.clearAPIRequests()
    QmlApi.buildGetReservesReq(pairAddress)
    var resp = JSON.parse(QmlApi.doAPIRequests())
    var reserves = QmlApi.parseHex(resp[0].result, ["uint", "uint", "uint"])
    var lowerAddress = QmlSystem.getFirstFromPair(
      fromAssetPopup.chosenAssetAddress, toAssetPopup.chosenAssetAddress
    )
    if (lowerAddress == fromAssetPopup.chosenAssetAddress) {
      inReserves = reserves[0]
      outReserves = reserves[1]
    } else if (lowerAddress == toAssetPopup.chosenAssetAddress) {
      inReserves = reserves[1]
      outReserves = reserves[0]
    }
  }

  function checkTransactionFunds() {
    if (fromAssetPopup.chosenAssetSymbol == "AVAX") {  // Coin
      var hasCoinFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.coinBalance, QmlSystem.calculateTransactionCost(
          swapInput.text, "180000", QmlSystem.getAutomaticFee()
        ), 18
      )
      return hasCoinFunds
    } else { // Token
      var hasCoinFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.coinBalance, QmlSystem.calculateTransactionCost(
          "0", "180000", QmlSystem.getAutomaticFee()
        ), 18
      )
      var hasTokenFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]["balance"],
        swapInput.text, fromAssetPopup.chosenAssetDecimals
      )
      return (hasCoinFunds && hasTokenFunds)
    }
  }

  AVMEPanel {
    id: exchangePanel
    width: (parent.width * 0.5)
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      margins: 10
    }
    title: "Exchange Details"

    Column {
      id: exchangeHeaderColumn
      height: (parent.height * 0.5) - anchors.topMargin
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        topMargin: 80
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 20

      Text {
        id: exchangeHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You will swap from <b>" + fromAssetPopup.chosenAssetSymbol
        + "</b> to <b>" + toAssetPopup.chosenAssetSymbol + "</b>"
      }

      Row {
        id: swapLogos
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20

        Image {
          id: fromLogo
          height: 48
          antialiasing: true
          smooth: true
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: 20
          fillMode: Image.PreserveAspectFit
          source: {
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (fromAssetPopup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(fromAssetPopup.chosenAssetAddress)
              source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          }
        }

        Text {
          id: swapOrder
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          font.pixelSize: 48.0
          text: " -> "
        }

        Image {
          id: toLogo
          height: 48
          antialiasing: true
          smooth: true
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: 20
          fillMode: Image.PreserveAspectFit
          source: {
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (toAssetPopup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (toAssetPopup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(toAssetPopup.chosenAssetAddress)
              source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          }
        }
      }

      Text {
        id: assetBalance
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Loading asset balance..."
        function refresh() {
          if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
            text = (accountHeader.coinBalance != "")
            ? "Total amount: <b>" + accountHeader.coinBalance + " AVAX</b>"
            : "Loading asset balance..."
          } else {
            var asset = accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]
            text = (asset != undefined)
            ? "Total amount: <b>" + asset["balance"]
            + " " + fromAssetPopup.chosenAssetSymbol + "</b>"
            : "Loading asset balance..."
          }
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEButton {
          id: btnChangeFrom
          width: (parent.parent.width * 0.5) - (parent.spacing / 2)
          text: "Change From Asset"
          onClicked: fromAssetPopup.open()
        }
        AVMEButton {
          id: btnChangeTo
          width: (parent.parent.width * 0.5) - (parent.spacing / 2)
          text: "Change To Asset"
          onClicked: toAssetPopup.open()
        }
      }
    }

    Column {
      id: exchangeApprovalColumn
      visible: !exchangeDetailsColumn.visible
      anchors {
        top: exchangeHeaderColumn.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 20
        bottomMargin: 20
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 20

      Text {
        id: exchangeApprovalText
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You need to approve your Account in order to swap <b>"
        + fromAssetPopup.chosenAssetSymbol + "</b>."
        + "<br>This operation will have a total gas cost of:<br><b>"
        + QmlSystem.calculateTransactionCost("0", "180000", QmlSystem.getAutomaticFee())
        + " AVAX</b>"
      }

      AVMEButton {
        id: approveBtn
        width: parent.width
        enabled: (+accountHeader.coinBalance >=
          +QmlSystem.calculateTransactionCost("0", "180000", QmlSystem.getAutomaticFee())
        )
        anchors.horizontalCenter: parent.horizontalCenter
        text: (enabled) ? "Approve" : "Not enough funds"
        onClicked: confirmApprovalPopup.open()
      }
    }

    Column {
      id: exchangeDetailsColumn
      anchors {
        top: exchangeHeaderColumn.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 20
        bottomMargin: 20
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 20

      AVMEInput {
        id: swapInput
        width: (parent.width * 0.8)
        validator: RegExpValidator {
          regExp: QmlSystem.createTxRegExp(fromAssetPopup.chosenAssetDecimals)
        }
        label: fromAssetPopup.chosenAssetSymbol + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: {
          swapEstimate = QmlSystem.calculateExchangeAmount(
            swapInput.text, inReserves, outReserves
          )
          swapImpact = QmlSystem.calculateExchangePriceImpact(
            inReserves, swapInput.text, 18
          )
        }

        AVMEButton {
          id: swapMaxBtn
          width: (parent.parent.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            swapInput.text = (fromAssetPopup.chosenAssetSymbol == "AVAX")
              ? QmlSystem.getRealMaxAVAXAmount(
                accountHeader.coinBalance, "180000", QmlSystem.getAutomaticFee()
              )
              : accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]["balance"]
            swapEstimate = QmlSystem.calculateExchangeAmount(
              swapInput.text, inReserves, outReserves
            )
            swapImpact = QmlSystem.calculateExchangePriceImpact(
              inReserves, swapInput.text, 18
            )
          }
        }
      }

      Text {
        id: swapEstimateText
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Estimated return: <b>"
        + swapEstimate + " " + toAssetPopup.chosenAssetSymbol + "</b> "
      }

      /**
       * Impact color metrics are as follows:
       * White  = 0%
       * Green  = 0.01~5%
       * Yellow = 5.01~7.5%
       * Orange = 7.51~10%
       * Red    = 10.01+%
       */
      Text {
        id: swapImpactText
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: {
          if (swapImpact == 0.0) {
            color: "#FFFFFF"
          } else if (swapImpact > 0.0 && swapImpact <= 5.0) {
            color: "#44FF44"
          } else if (swapImpact > 5.0 && swapImpact <= 7.5) {
            color: "#FFFF44"
          } else if (swapImpact > 7.5 && swapImpact <= 10.0) {
            color: "#FF8844"
          } else if (swapImpact > 10.0) {
            color: "#FF4444"
          }
        }
        font.pixelSize: 14.0
        text: "Price impact: <b>" + swapImpact + "%</b>"
      }

      CheckBox {
        id: ignoreImpactCheck
        checked: false
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Ignore price impact"
        contentItem: Text {
          text: parent.text
          font.pixelSize: 14.0
          color: parent.checked ? "#FFFFFF" : "#888888"
          verticalAlignment: Text.AlignVCenter
          leftPadding: parent.indicator.width + parent.spacing
        }
      }

      AVMEButton {
        id: swapBtn
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (
          swapInput.acceptableInput && (swapImpact <= 10.0 || ignoreImpactCheck.checked)
        )
        text: (swapImpact <= 10.0 || ignoreImpactCheck.checked)
        ? "Make Swap" : "Price impact too high"
        onClicked: {
          if (!checkTransactionFunds()) {
            fundsPopup.open()
          } else {
            // TODO: fix Ledger
            //if (QmlSystem.getLedgerFlag()) {
            //  checkLedger()
            //} else {
            //  confirmExchangePopup.open()
            //}
            confirmExchangePopup.open()
          }
        }
        /*
        onClicked: {
          if (!QmlSystem.isApproved(swapInput.text, allowance)) {
            QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            QmlSystem.operationOverride("Approve Exchange", "", "", "")
          } else if (coinToToken) {
            if (QmlSystem.balanceIsZero(swapInput.text, 18)) {
              zeroSwapPopup.open()
            } else {
              if (QmlSystem.hasInsufficientFunds(
                "Coin", QmlSystem.getRealMaxAVAXAmount("180000", QmlSystem.getAutomaticFee()), swapInput.text
              )) {
                fundsPopup.open()
              } else {
                QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
                QmlSystem.operationOverride("Swap AVAX -> AVME", swapInput.text, swapEstimate, "")
              }
            }
          } else {
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            if (QmlSystem.balanceIsZero(swapInput.text, 18)) {
              zeroSwapPopup.open()
            } else {
              if (QmlSystem.hasInsufficientFunds("Token", acc.balanceAVME, swapInput.text)) {
                fundsPopup.open()
              } else {
                QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
                QmlSystem.operationOverride("Swap AVME -> AVAX", swapEstimate, swapInput.text, "")
              }
            }
          }
        }
        */
      }
    }
  }

  // Popups for choosing the asset going "in"/"out".
  // Defaults to "from AVAX to AVME".
  AVMEPopupAssetSelect {
    id: fromAssetPopup
    defaultToAVME: false
    Component.onCompleted: fetchAllowance()
    onAboutToHide: {
      if (chosenAssetAddress == toAssetPopup.chosenAssetAddress) {
        if (chosenAssetAddress == QmlSystem.getContract("AVAX")) {
          toAssetPopup.forceAVME()
        } else {
          toAssetPopup.forceAVAX()
        }
      }
      fetchAllowance()
    }
  }
  AVMEPopupAssetSelect {
    id: toAssetPopup
    defaultToAVME: true
    onAboutToHide: {
      if (chosenAssetAddress == fromAssetPopup.chosenAssetAddress) {
        if (chosenAssetAddress == QmlSystem.getContract("AVAX")) {
          fromAssetPopup.forceAVME()
        } else {
          fromAssetPopup.forceAVAX()
        }
      }
      fetchAllowance()
    }
  }

  // Popup for insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
  AVMEPopupInfo {
    id: zeroSwapPopup
    icon: "qrc:/img/warn.png"
    info: "Cannot send swap for 0 value"
  }

  // Popups for confirming approval and swap, respectively
  AVMEPopupConfirmTx {
    id: confirmApprovalPopup
    info: "You will approve "
    + "<b>" + fromAssetPopup.chosenAssetSymbol + "</b>"
    + " swapping to the current address<br>"
    + "<br>Gas Limit: <b>"
    + QmlSystem.weiToFixedPoint("180000", 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + QmlSystem.weiToFixedPoint(QmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
  AVMEPopupConfirmTx {
    id: confirmExchangePopup
    info: "You will swap "
    + "<b>" + swapInput.text + " " + fromAssetPopup.chosenAssetSymbol + "</b><br>"
    + "for <b>" + swapEstimate + " " + toAssetPopup.chosenAssetSymbol + "</b>"
    + "<br>Gas Limit: <b>"
    + QmlSystem.weiToFixedPoint("180000", 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + QmlSystem.weiToFixedPoint(QmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
}
