// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLAPI
#define QMLAPI

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QFile>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>
#include <QtGui/QClipboard>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtWidgets/QApplication>

#include <network/API.h>
#include <core/BIP39.h>
#include <core/ABI.h>
#include <core/Utils.h>
#include <core/Wallet.h>
#include <lib/nlohmann_json/json.hpp>

class QmlApi : public QObject {
  Q_OBJECT

  private:
    std::vector<Request> requestList;

  public:
    /**
     * Call every request under requestList in a single connection.
     * Automatically clears the requestList when done.
     */
    Q_INVOKABLE QString doAPIRequests();

    /**
     * Manually clear the requestList if necessary.
     */
    Q_INVOKABLE void clearAPIRequests();

    /**
     * Build requests for getting the AVAX and a given token's balance, respectively.
     */
    Q_INVOKABLE void buildGetBalanceReq(QString address);
    Q_INVOKABLE void buildGetTokenBalanceReq(QString contract, QString address);

    /**
     * Build request for getting the current block number.
     */
    Q_INVOKABLE void buildGetCurrentBlockNumberReq();

    /**
     * Build request for getting the highest available nonce for the given address.
     */
    Q_INVOKABLE void buildGetNonceReq(std::string address);

    /**
     * Build request for getting the receipt (details) of a transaction.
     * e.g. blockNumber, status, etc.
     */
    Q_INVOKABLE void buildGetTxReceiptReq(std::string txidHex);

    /**
     * Build request for getting the estimated gas limit.
     */
    Q_INVOKABLE void buildGetEstimateGasLimitReq();

    /**
     * Get an ARC20 token's data.
     */
    Q_INVOKABLE void buildGetARC20TokenDataReq(std::string address);

    /**
     * Functions for appending custom ABI calls.
     */
    Q_INVOKABLE void buildCustomEthCallReq(QString contract, QString ABI);
    Q_INVOKABLE QString buildCustomABI(QString input);
};

#endif // QMLAPI_H
