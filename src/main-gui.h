// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QFile>
#include <QtCore/QString>
#include <QtCore/QVariant>
#include <QtCore/qplugin.h>
#include <QtGui/QClipboard>
#include <QtGui/QFont>
#include <QtGui/QFontDatabase>
#include <QtGui/QIcon>
#include <QtGui/QScreen>
#include <QtCore/QThread>
#include <QtCore/QDateTime>
#include <QtConcurrent/qtconcurrentrun.h>

#ifdef __MINGW32__
Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)
// Redefine the WINNT version for MinGW, use Windows 7 instead of Windows XP
#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0601
#define WINVER 0x0601
#else
Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
#undef FONTCONFIG_PATH
#define FONTCONFIG_PATH "/etc/fonts" // Redefine fontconfig path for the program
#endif
Q_IMPORT_PLUGIN(QtQuick2Plugin)
Q_IMPORT_PLUGIN(QtQuick2WindowPlugin)
Q_IMPORT_PLUGIN(QtQuickTemplates2Plugin)
Q_IMPORT_PLUGIN(QtQuickControls2Plugin)
Q_IMPORT_PLUGIN(QtLabsPlatformPlugin)
Q_IMPORT_PLUGIN(QtChartsQml2Plugin)

#include "lib/Account.h"
#include "lib/API.h"
#include "lib/BIP39.h"
#include "lib/Coin.h"
#include "lib/Graph.h"
#include "lib/Pangolin.h"
#include "lib/Staking.h"
#include "lib/Token.h"
#include "lib/Utils.h"
#include "lib/Wallet.h"

#include "version.h"

// QObject/wrapper for interfacing between C++ (wallet) and QML (gui)
class System : public QObject {
  Q_OBJECT

  signals:
    void hideMenu();
    void goToOverview();
    void coinChanged();
    void tokenChanged();
    void accountsGenerated(QVariantList accounts);
    void accountCreated();
    void accountCreationFailed();
    void accountBalancesUpdated(QVariantMap data);
    void accountFiatBalancesUpdated(QVariantMap data);
    void walletBalancesUpdated(QVariantMap data);
    void walletFiatBalancesUpdated(QVariantMap data);
    void roiCalculated(QString ROI);
    void marketDataUpdated(
      int days, QString currentAVAXPrice, QString currentAVMEPrice, QVariantList AVMEHistory
    );
    void historyLoaded(QVariantList data);
    void operationOverride(QString op, QString amountCoin, QString amountToken, QString amountLP);
    void txStart(
      QString operation, QString to,
      QString coinAmount, QString tokenAmount, QString lpAmount,
      QString gasLimit, QString gasPrice, QString pass
    );
    void txBuilt(bool b);
    void txSigned(bool b);
    void txSent(bool b, QString linkUrl);
    void txRetry();
    void allowancesUpdated(
      QString exchangeAllowance, QString liquidityAllowance, QString stakingAllowance
    );
    void exchangeDataUpdated(
      QString lowerTokenName, QString lowerTokenReserves,
      QString higherTokenName, QString higherTokenReserves
    );
    void liquidityDataUpdated(
      QString lowerTokenName, QString lowerTokenReserves,
      QString higherTokenName, QString higherTokenReserves,
      QString totalLiquidity
    );
    void rewardUpdated(QString poolReward);

  private:
    Wallet w;

  public:
    // =======================================================================
    // GETTERS/SETTERS
    // =======================================================================
    // TODO: fix all of this
    Q_INVOKABLE QString getCurrentAccount() {
      return QString::fromStdString(this->w.currentAccount.address);
    }
    Q_INVOKABLE void setCurrentAccount(QString account) {
      this->w.setAccount(account.toStdString());
    }

    Q_INVOKABLE QString getCurrentCoinName() {
      return QString::fromStdString(this->w.currentAccount.currentCoin.getName());
    }
    Q_INVOKABLE void setCurrentCoinName(QString coin) {
      //this->w.currentAccount.currentCoin.name = coin.toStdString();
    }

    Q_INVOKABLE QString getCurrentTokenName() {
      return QString::fromStdString(this->w.currentAccount.currentToken.getName());
    }
    Q_INVOKABLE void setCurrentTokenName(QString token) {
      //this->w.currentAccount.currentToken.name = token.toStdString();
    }

    Q_INVOKABLE QString getCurrentTokenAddress() {
      return QString::fromStdString(this->w.currentAccount.currentToken.getAddress());
    }
    Q_INVOKABLE void setCurrentTokenAddress(QString address) {
      //this->w.currentAccount.currentToken.address = address.toStdString();
    }

    Q_INVOKABLE int getCurrentCoinDecimals() {
      return this->w.currentAccount.currentCoin.getDecimals();
    }
    Q_INVOKABLE void setCurrentCoinDecimals(int decimals) {
      //this->w.currentAccount.currentCoin.decimals = decimals;
    }

    Q_INVOKABLE int getCurrentTokenDecimals() {
      return this->w.currentAccount.currentToken.getDecimals();
    }
    Q_INVOKABLE void setCurrentTokenDecimals(int decimals) {
      //this->w.currentAccount.currentToken.decimals = decimals;
    }

    Q_INVOKABLE bool getCurrentTokenIsTradeable() {
      return this->w.currentAccount.currentToken.isTradeable();
    }
    Q_INVOKABLE void setCurrentTokenIsTradeable(bool b) {
      //this->w.currentAccount.currentToken.tradeable = b;
    }

    // TODO: isStakeable

    // =======================================================================
    // QT-SPECIFIC STUFF
    // =======================================================================

    // Get the project's version
    Q_INVOKABLE QString getProjectVersion() {
      return QString::fromStdString(PROJECT_VERSION);
    }

    // Open the "About Qt" window
    Q_INVOKABLE void openQtAbout() {
      QApplication::aboutQt();
    }

    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }

    // Copy a string to the system clipboard
    Q_INVOKABLE void copyToClipboard(QString str) {
      QApplication::clipboard()->setText(str);
    }

    // =======================================================================
    // WALLET-SPECIFIC WRAPPERS
    // =======================================================================

    // Get the default path for a Wallet
    Q_INVOKABLE QString getDefaultWalletPath() {
      return QString::fromStdString(JSON::getDataDir().string());
    }

    // Remove the "file://" prefix from a folder path
    Q_INVOKABLE QString cleanPath(QString path) {
      #ifdef __MINGW32__
        return path.remove("file:///");
      #else
        return path.remove("file://");
      #endif
    }

    // Check if a Wallet exists in a given folder
    Q_INVOKABLE bool checkFolderForWallet(QString folder) {
      QString walletFile = QString(folder + "/wallet/c-avax/wallet.info");
      QString secretsFolder = QString(folder + "/wallet/c-avax/accounts/secrets");
      return (QFile::exists(walletFile) && QFile::exists(secretsFolder));
    }

    // Check if given passphrase equals the Wallet's
    Q_INVOKABLE bool checkWalletPass(QString pass) {
      return w.auth(pass.toStdString());
    }

    // Create, import, load and close a Wallet, respectively
    Q_INVOKABLE bool createWallet(QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool createSuccess = this->w.create(folder.toStdString(), passStr);
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic = BIP39::createNewMnemonic();
      std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
      return (createSuccess && seedSuccess.first);
    }

    Q_INVOKABLE bool importWallet(QString seed, QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool createSuccess = this->w.create(folder.toStdString(), passStr);
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
      mnemonic.raw = seed.toStdString();
      std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
      return (createSuccess && seedSuccess.first);
    }

    Q_INVOKABLE bool loadWallet(QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool loadSuccess = this->w.load(folder.toStdString(), passStr);
      return loadSuccess;
    }

    Q_INVOKABLE void closeWallet() {
      this->w.close();
    }

    // Check if a Wallet is loaded
    Q_INVOKABLE bool isWalletLoaded() {
      return this->w.isLoaded();
    }

    // Get the seed for the Wallet
    Q_INVOKABLE QString getWalletSeed(QString pass) {
      std::string passStr = pass.toStdString();
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
      std::pair<bool,std::string> seedSuccess = BIP39::loadEncryptedMnemonic(mnemonic, passStr);
      return (seedSuccess.first) ? QString::fromStdString(mnemonic.raw) : "";
    }

    // =======================================================================
    // ACCOUNT-SPECIFIC WRAPPERS
    // =======================================================================

    // Get a list of Account addresses and names in the Wallet
    Q_INVOKABLE QVariantList getAccounts() {
      QVariantList ret;
      std::map<std::string, std::string> accounts = this->w.getAccounts();
      for (std::pair<std::string, std::string> account : accounts) {
        std::string obj;
        obj += "{\"account\": \"" + account.first;
        obj += "\", \"name\": \"" + account.second;
        obj += "\", \"coinAmount\": \"\"}";
        ret << QString::fromStdString(obj);
      }
      return ret;
    }

    // Generate an Account list from a given seed, starting from a given index
    Q_INVOKABLE void generateAccounts(QString seed, int idx) {
      QtConcurrent::run([=](){
        QVariantList ret;
        std::vector<std::string> list = BIP39::generateAccountsFromSeed(seed.toStdString(), idx);
        for (std::string s : list) {
          std::stringstream listss(s);
          std::string item, obj;
          int ct = 0;
          while (std::getline(listss, item, ' ')) {
            switch (ct) {
              case 0: obj += "{\"idx\": \"" + item; break;
              case 1: obj += "\", \"account\": \"" + item; break;
              case 2: obj += "\", \"balance\": \"" + item; break;
            }
            ct++;
          }
          obj += "\"}";
          ret << QString::fromStdString(obj);
        }
        emit accountsGenerated(ret);
      });
    }

    // Create a new Account
    Q_INVOKABLE void createAccount(QString seed, int index, QString name, QString pass) {
      QtConcurrent::run([=](){
        std::string seedStr = seed.toStdString();
        std::string nameStr = name.toStdString();
        std::string passStr = pass.toStdString();
        if (this->w.createAccount(seedStr, index, nameStr, passStr)) {
          emit accountCreated();
        } else {
          emit accountCreationFailed();
        }
      });
    }

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account) {
      return this->w.eraseAccount(account.toStdString());
    }

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account) {
      return this->w.accountExists(account.toStdString());
    }

    // =======================================================================
    // COIN/TOKEN-SPECIFIC WRAPPERS
    // =======================================================================

    // Set the default coin (AVAX) and token (AVME), respectively
    Q_INVOKABLE void setDefaultCoin() {
      this->w.currentAccount.setDefaultCoin();
      emit coinChanged();
    }
    Q_INVOKABLE void setDefaultToken() {
      this->w.currentAccount.setDefaultToken();
      emit tokenChanged();
    }

    // Set the current token
    // TODO: fix this
    /*
    Q_INVOKABLE void setToken(QString address, QString symbol, int decimals) {
      this->w.setToken(address.toStdString(), symbol.toStdString(), decimals);
      this->w.currentTokenIsTradeable = (symbol == "AVME")
        ? true : Graph::isTokenTradeable(address.toStdString());
      emit tokenChanged();
    }
    */

    // Get the token list from the Wallet
    Q_INVOKABLE QVariantList getTokenList() {
      QVariantList ret;
      std::vector<Token> tokenList = this->w.getTokenList();
      for (Token t : tokenList) {
        std::string obj;
        std::string address = t.getAddress();
        std::string name = t.getName();
        std::string symbol = t.getSymbol();
        int decimals = t.getDecimals();
        std::string icon = t.getIcon();

        if (icon.empty()) {
          icon = "qrc:/img/icons/unknownToken.png";
        } else {
          #ifdef __MINGW32__
            icon.insert(0, "file:///");
          #else
            icon.insert(0, "file://");
          #endif
        }
        obj += "{\"address\": \"" + address;
        obj += "\", \"name\": \"" + name;
        obj += "\", \"symbol\": \"" + symbol;
        obj += "\", \"decimals\": " + std::to_string(decimals);
        obj += ", \"icon\": \"" + icon;
        obj += "\"}";
        ret << QString::fromStdString(obj);
      }
      return ret;
    }

    // Check if a token exists in the blockchain
    Q_INVOKABLE bool isERC20Token(QString address) {
      std::string addressStr = address.toStdString();
      std::transform(addressStr.begin(), addressStr.end(), addressStr.begin(), ::tolower);
      return API::isERC20Token(addressStr);
    }

    // Get a token's data
    Q_INVOKABLE QVariantMap getERC20TokenData(QString address) {
      QVariantMap ret;
      std::string addressStr = address.toStdString();
      std::transform(addressStr.begin(), addressStr.end(), addressStr.begin(), ::tolower);
      std::pair<std::string, int> data = API::getERC20TokenData(addressStr);
      if (!data.first.empty()) {
        ret.insert("symbol", QString::fromStdString(data.first));
        ret.insert("decimals", QString::number(data.second));
      }
      return ret;
    }

    // Add/remove a token to/from the list, respectively.
    // TODO: get icons that are not in repo (e.g. VSO)
    Q_INVOKABLE bool addTokenToList(QString address) {
      std::string addressStr = address.toStdString();
      std::string nameStr;  // TODO: fill this
      std::transform(addressStr.begin(), addressStr.end(), addressStr.begin(), ::tolower);
      std::pair<std::string, int> tokenData = API::getERC20TokenData(addressStr);
      if (tokenData.first.empty()) { return false; }
      boost::filesystem::path iconPath = Utils::walletFolderPath.string()
        + "/wallet/c-avax/tokens/" + tokenData.first + ".png";
      if (!exists(iconPath)) {
        API::httpGetFile(
          "raw.githubusercontent.com",
          "/ava-labs/bridge-tokens/main/avalanche-tokens/" +
            Utils::toChecksumAddress(addressStr) + "/logo.png",
          iconPath.string()
        );
      }
      return this->w.addTokenToList(
        Token::Type::ERC20, addressStr, nameStr,
        tokenData.first, tokenData.second, iconPath.string()
      );
    }

    Q_INVOKABLE bool removeTokenFromList(QString address) {
      std::string addressStr = address.toStdString();
      std::transform(addressStr.begin(), addressStr.end(), addressStr.begin(), ::tolower);
      return this->w.removeTokenFromList(addressStr);
    }

    // Check if token was already added to the Wallet
    Q_INVOKABLE bool tokenIsAdded(QString address) {
      std::string addressStr = address.toStdString();
      std::transform(addressStr.begin(), addressStr.end(), addressStr.begin(), ::tolower);
      return this->w.tokenIsAdded(addressStr);
    }

    // Get the icon for the selected token
    /*
    Q_INVOKABLE QString getCurrentTokenIcon() {
      std::string tokenName = this->w.currentAccount.currentToken.name;
      if (tokenName == "AVME") {
        return QString::fromStdString("qrc:/img/avme_logo.png");
      } else {
        boost::filesystem::path iconPath = Utils::walletFolderPath.string()
          + "/wallet/c-avax/tokens/" + tokenName + ".png";
        return (exists(iconPath))
          ? QString::fromStdString(iconPath.string())
          : QString::fromStdString("qrc:/img/icons/unknownToken.png");
      }
    }
    */

    // List the Account's transactions, updating their statuses on the spot if required
    Q_INVOKABLE void listAccountTransactions(QString address) {
      QtConcurrent::run([=](){
        QVariantList ret;
        this->w.currentAccount.updateAllTxStatus();
        this->w.currentAccount.loadTxHistory();
        for (TxData tx : this->w.currentAccount.history) {
          std::string obj;
          obj += "{\"txlink\": \"" + tx.txlink;
          obj += "\", \"operation\": \"" + tx.operation;
          obj += "\", \"txdata\": \"" + tx.data;
          obj += "\", \"from\": \"" + tx.from;
          obj += "\", \"to\": \"" + tx.to;
          obj += "\", \"value\": \"" + tx.value;
          obj += "\", \"gas\": \"" + tx.gas;
          obj += "\", \"price\": \"" + tx.price;
          obj += "\", \"datetime\": \"" + tx.humanDate;
          obj += "\", \"unixtime\": " + std::to_string(tx.unixDate);
          obj += ", \"confirmed\": " + QVariant(tx.confirmed).toString().toStdString();
          obj += ", \"invalid\": " + QVariant(tx.invalid).toString().toStdString();
          obj += "}";
          ret << QString::fromStdString(obj);
        }
        emit historyLoaded(ret);
      });
    }

    // Get the current Account's balances
    // TODO: use this on overview too
    Q_INVOKABLE QVariantMap getCurrentAccountBalances() {
      QVariantMap ret;
      std::string balanceAVAXStr, balanceAVMEStr, balanceLPFreeStr, balanceLPLockedStr;
      this->w.currentAccount.balancesThreadLock.lock();
      balanceAVAXStr = this->w.currentAccount.balanceAVAX;
      balanceAVMEStr = this->w.currentAccount.balanceAVME;
      balanceLPFreeStr = this->w.currentAccount.balanceLPFree;
      balanceLPLockedStr = this->w.currentAccount.balanceLPLocked;
      this->w.currentAccount.balancesThreadLock.unlock();
      ret.insert("balanceAVAX", QString::fromStdString(balanceAVAXStr));
      ret.insert("balanceAVME", QString::fromStdString(balanceAVMEStr));
      ret.insert("balanceLPFree", QString::fromStdString(balanceLPFreeStr));
      ret.insert("balanceLPLocked", QString::fromStdString(balanceLPLockedStr));
      return ret;
    }

    // Query and calculate fiat pricings for the given balances
    // TODO: check this and use on overview
    Q_INVOKABLE void calculateFiatBalances(QString coinBalance, QString tokenBalance) {
      QtConcurrent::run([=](){
        QVariantMap ret;
        std::string coinBalanceStr = coinBalance.toStdString();
        std::string tokenBalanceStr = tokenBalance.toStdString();

        // Get base prices from the network
        std::string coinUnitPrice = Graph::getAVAXPriceUSD();
        std::string tokenUnitPrice = Graph::getAVMEPriceUSD(coinUnitPrice);
        bigfloat coinPriceFloat =
          boost::lexical_cast<double>(coinBalanceStr) * boost::lexical_cast<double>(coinUnitPrice);
        bigfloat tokenPriceFloat =
          boost::lexical_cast<double>(tokenBalanceStr) * boost::lexical_cast<double>(tokenUnitPrice);
        std::string coinPrice = boost::lexical_cast<std::string>(coinPriceFloat);
        std::string tokenPrice = boost::lexical_cast<std::string>(tokenPriceFloat);

        // Round the fiat balances to two decimals
        std::stringstream coinPricess, tokenPricess;
        coinPricess << std::setprecision(2) << std::fixed << bigfloat(coinPrice);
        tokenPricess << std::setprecision(2) << std::fixed << bigfloat(tokenPrice);
        coinPrice = coinPricess.str();
        tokenPrice = tokenPricess.str();

        // Fiat percentages (for the chart)
        bigfloat totalUSD, coinPercentageFloat, tokenPercentageFloat;
        totalUSD = boost::lexical_cast<double>(coinPrice) + boost::lexical_cast<double>(tokenPrice);
        if (totalUSD == 0) {
          coinPercentageFloat = tokenPercentageFloat = 0;
        } else {
          coinPercentageFloat = (boost::lexical_cast<double>(coinPrice) / totalUSD) * 100;
          tokenPercentageFloat = (boost::lexical_cast<double>(tokenPrice) / totalUSD) * 100;
        }

        // Round the percentages to two decimals
        std::stringstream coinPercentagess, tokenPercentagess;
        coinPercentagess << std::setprecision(2) << std::fixed << bigfloat(coinPercentageFloat);
        tokenPercentagess << std::setprecision(2) << std::fixed << bigfloat(tokenPercentageFloat);
        std::string coinPercentage = coinPercentagess.str();
        std::string tokenPercentage = tokenPercentagess.str();

        // Pack up fiat balances and send back to GUI
        ret.insert("balanceCoinUSD", QString::fromStdString(coinPrice));
        ret.insert("balanceTokenUSD", QString::fromStdString(tokenPrice));
        ret.insert("percentageCoinUSD", QString::fromStdString(coinPercentage));
        ret.insert("percentageTokenUSD", QString::fromStdString(tokenPercentage));

        emit accountFiatBalancesUpdated(ret);
      });
    }

    // Get the sum of all Accounts' balances in the Wallet for the Overview
    // TODO: fix this to not use the vector anymore, also rework this due to currentAccount
    /*
    Q_INVOKABLE void getAllAccountBalancesOverview() {
      QtConcurrent::run([=](){
        QVariantMap ret;
        u256 totalAVAX = 0, totalAVME = 0, totalLPFree = 0, totalLPLocked = 0;
        std::string totalAVAXStr = "", totalAVMEStr = "", totalLPFreeStr = "", totalLPLockedStr = "";

        // Whole balances
        for (Account &a : w.accounts) {
          a.balancesThreadLock.lock();
          totalAVAX += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceAVAX, this->w.currentCoinDecimals)
          );
          totalAVME += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceAVME, this->w.currentTokenDecimals)
          );
          totalLPFree += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceLPFree, 18)
          );
          totalLPLocked += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceLPLocked, 18)
          );
          a.balancesThreadLock.unlock();
        }
        totalAVAXStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalAVAX), this->w.currentCoinDecimals
        );
        totalAVMEStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalAVME), this->w.currentTokenDecimals
        );
        totalLPFreeStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalLPFree), 18
        );
        totalLPLockedStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalLPLocked), 18
        );

        // Pack up and send back to GUI
        ret.insert("balanceAVAX", QString::fromStdString(totalAVAXStr));
        ret.insert("balanceAVME", QString::fromStdString(totalAVMEStr));
        ret.insert("balanceLPFree", QString::fromStdString(totalLPFreeStr));
        ret.insert("balanceLPLocked", QString::fromStdString(totalLPLockedStr));
        emit walletBalancesUpdated(ret);
      });
    }
    */

    // Same as above but for fiat balances
    // TODO: fix this to not use the vector anymore, also rework this due to currentAccount
    /*
    Q_INVOKABLE void getAllAccountFiatBalancesOverview() {
      QtConcurrent::run([=](){
        QVariantMap ret;
        u256 totalAVAX = 0, totalAVME = 0, totalLPFree = 0, totalLPLocked = 0;
        std::string totalAVAXStr = "", totalAVMEStr = "", totalLPFreeStr = "", totalLPLockedStr = "";

        // Whole balances
        for (Account &a : w.accounts) {
          a.balancesThreadLock.lock();
          totalAVAX += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceAVAX, this->w.currentCoinDecimals)
          );
          totalAVME += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceAVME, this->w.currentTokenDecimals)
          );
          totalLPFree += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceLPFree, 18)
          );
          totalLPLocked += boost::lexical_cast<u256>(
            Utils::fixedPointToWei(a.balanceLPLocked, 18)
          );
          a.balancesThreadLock.unlock();
        }
        totalAVAXStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalAVAX), this->w.currentCoinDecimals
        );
        totalAVMEStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalAVME), this->w.currentTokenDecimals
        );
        totalLPFreeStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalLPFree), 18
        );
        totalLPLockedStr = Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(totalLPLocked), 18
        );

        // Fiat balances
        std::string AVAXUnitPrice = Graph::getAVAXPriceUSD();
        std::string AVMEUnitPrice = Graph::getAVMEPriceUSD(AVAXUnitPrice);
        bigfloat AVAXPriceFloat =
          boost::lexical_cast<double>(totalAVAXStr) * boost::lexical_cast<double>(AVAXUnitPrice);
        bigfloat AVMEPriceFloat =
          boost::lexical_cast<double>(totalAVMEStr) * boost::lexical_cast<double>(AVMEUnitPrice);
        std::string AVAXPrice = boost::lexical_cast<std::string>(AVAXPriceFloat);
        std::string AVMEPrice = boost::lexical_cast<std::string>(AVMEPriceFloat);

        // Round the fiat balances to two decimals
        std::stringstream AVAXPricess, AVMEPricess;
        AVAXPricess << std::setprecision(2) << std::fixed << bigfloat(AVAXPrice);
        AVMEPricess << std::setprecision(2) << std::fixed << bigfloat(AVMEPrice);
        AVAXPrice = AVAXPricess.str();
        AVMEPrice = AVMEPricess.str();

        // Fiat percentages (for the chart)
        bigfloat totalUSD, AVAXPercentageFloat, AVMEPercentageFloat;
        totalUSD = boost::lexical_cast<double>(AVAXPrice) + boost::lexical_cast<double>(AVMEPrice);
        if (totalUSD == 0) {
          AVAXPercentageFloat = AVMEPercentageFloat = 0;
        } else {
          AVAXPercentageFloat = (boost::lexical_cast<double>(AVAXPrice) / totalUSD) * 100;
          AVMEPercentageFloat = (boost::lexical_cast<double>(AVMEPrice) / totalUSD) * 100;
        }

        // Round the percentages to two decimals
        std::stringstream AVAXPercentagess, AVMEPercentagess;
        AVAXPercentagess << std::setprecision(2) << std::fixed << bigfloat(AVAXPercentageFloat);
        AVMEPercentagess << std::setprecision(2) << std::fixed << bigfloat(AVMEPercentageFloat);
        std::string AVAXPercentage = AVAXPercentagess.str();
        std::string AVMEPercentage = AVMEPercentagess.str();

        // Pack up and send back to GUI
        ret.insert("balanceAVAXUSD", QString::fromStdString(AVAXPrice));
        ret.insert("balanceAVMEUSD", QString::fromStdString(AVMEPrice));
        ret.insert("percentageAVAXUSD", QString::fromStdString(AVAXPercentage));
        ret.insert("percentageAVMEUSD", QString::fromStdString(AVMEPercentage));
        emit walletFiatBalancesUpdated(ret);
      });
    }
    */

    // Get the current ROI for the staking reward
    Q_INVOKABLE void calculateRewardCurrentROI() {
      QtConcurrent::run([=](){
        // Get the prices in USD for both AVAX and AVME
        std::string AVAXPrice = Graph::getAVAXPriceUSD();
        std::string AVMEPrice = Graph::getAVMEPriceUSD(AVAXPrice);
        bigfloat AVAXUnitPrice = boost::lexical_cast<double>(AVAXPrice);
        bigfloat AVMEUnitPrice = boost::lexical_cast<double>(AVMEPrice);

        // From 1 AVAX, calculate the optimal amount of AVME that would go to the pool
        std::vector<std::string> reserves = Pangolin::getReserves("WAVAX", "AVME");
        std::string first = Pangolin::getFirstFromPair("WAVAX", "AVME");
        bigfloat AVAXreserves = ("WAVAX" == first)
          ? boost::lexical_cast<bigfloat>(u256(reserves[0]))
          : boost::lexical_cast<bigfloat>(u256(reserves[1]));
        bigfloat AVMEreserves = ("AVME" == first)
          ? boost::lexical_cast<bigfloat>(u256(reserves[0]))
          : boost::lexical_cast<bigfloat>(u256(reserves[1]));
        bigfloat AVAXamount = bigfloat(Utils::fixedPointToWei(
          "1", this->w.currentAccount.currentCoin.getDecimals()
        ));
        // Amount and reserves are converted back to a non-scientific notation number
        bigfloat AVMEamount = bigfloat(Pangolin::calcLiquidityAmountOut(
          boost::lexical_cast<std::string>(u256(AVAXamount)),
          boost::lexical_cast<std::string>(u256(AVAXreserves)),
          boost::lexical_cast<std::string>(u256(AVMEreserves))
        ));

        // Use both values in Wei amounts to calculate the amount of LP that would be received
        bigfloat LPsupply = bigfloat(Utils::weiToFixedPoint(Staking::totalSupply(), 18));
        bigfloat LPamount = std::min(
          (AVAXamount * bigfloat(Utils::fixedPointToWei(
            boost::lexical_cast<std::string>(LPsupply), 18)
          )) / AVAXreserves,
          (AVMEamount * bigfloat(Utils::fixedPointToWei(
            boost::lexical_cast<std::string>(LPsupply), 18)
          )) / AVMEreserves
        );
        // Amount is converted back to a non-scientific notation number
        LPamount = bigfloat(Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(u256(LPamount)), 18)
        );

        // Get the reward value and duration from the staking contract
        bigfloat reward = bigfloat(Staking::getRewardForDuration());
        bigfloat duration = bigfloat(Staking::rewardsDuration()) / 86400;
        bigfloat rewardPerDuration = reward / duration; // 86400 seconds = 1 day
        rewardPerDuration = bigfloat(Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(u256(rewardPerDuration)), 18)
        );

        /**
         * Calculate the ROI, based on the following formula:
         * A = AVAXUnitPrice, B = AVMEUnitPrice, C = LPamount, D = rewardPerDuration, E = LPsupply
         * ROI = ((((C / E) * D) * 365) * B) / (A * 2) * 100
         */
        bigfloat ROI = (
          ((((LPamount / LPsupply) * rewardPerDuration) * 365) * AVMEUnitPrice) / (AVAXUnitPrice * 2)
        ) * 100;

        // Round the percentage to two decimals and return it
        std::stringstream ROIss;
        ROIss << std::setprecision(2) << std::fixed << ROI;
        emit roiCalculated(QString::fromStdString(ROIss.str()));
      });
    }

    // Get data for the market chart, from most to least recent in a given amount of days
    Q_INVOKABLE void getMarketData(int days) {
      QtConcurrent::run([=](){
        std::string AVAXUnitPrice, AVMEUnitPrice;
        std::vector<std::map<std::string, std::string>> listUSDT, listAVME;
        QVariantList graphRet;

        // Get the current AVAX price in fiat (USD) and round it to two decimals
        AVAXUnitPrice = Graph::getAVAXPriceUSD();
        AVMEUnitPrice = Graph::getAVMEPriceUSD(AVAXUnitPrice);
        std::stringstream AVAXss;
        AVAXss << std::setprecision(2) << std::fixed << bigfloat(AVAXUnitPrice);
        AVAXUnitPrice = AVAXss.str();

        // Get the historical AVME prices in fiat (USD) and send back
        listUSDT = Graph::getUSDTPriceHistory(days);
        listAVME = Graph::getAVMEPriceHistory(days);
        for (std::map<std::string, std::string> mapUSDT : listUSDT) {
          for (std::map<std::string, std::string> mapAVME : listAVME) {
            if (mapUSDT["date"] == mapAVME["date"]) {
              std::string obj;
              bigfloat realAVMEValue = (
                (1 / bigfloat(mapUSDT["priceUSD"])) * bigfloat(mapAVME["priceUSD"])
              );
              obj += "{\"unixdate\": " + mapAVME["date"];
              obj += ", \"priceUSD\": " + boost::lexical_cast<std::string>(realAVMEValue);
              obj += "}";
              graphRet << QString::fromStdString(obj);
            }
          }
        }
        emit marketDataUpdated(
          days,
          QString::fromStdString(AVAXUnitPrice),
          QString::fromStdString(AVMEUnitPrice),
          graphRet
        );
      });
    }

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass) {
      Secret s = w.getSecret(account.toStdString(), pass.toStdString());
      std::string key = toHex(s.ref());
      return QString::fromStdString(key);
    }

    // Check if Account seed is valid
    Q_INVOKABLE bool seedIsValid(QString seed) {
      std::stringstream ss(seed.toStdString());
      std::string word;
      int ct = 0;

      while (std::getline(ss, word, ' ')) {
        if (!BIP39::wordExists(word)) { return false; }
        ct++;
      }
      if (ct != 12) { return false; }

      return true;
    }

    // Get gas price from network
    Q_INVOKABLE QString getAutomaticFee() {
      return QString::fromStdString(API::getAutomaticFee());
    }

    // Create a RegExp for coin and token transaction amount input, respectively
    Q_INVOKABLE QRegExp createCoinRegExp() {
      QRegExp rx;
      rx.setPattern(
        "[0-9]{1,}(?:\\.[0-9]{1," +
        QString::number(this->w.currentAccount.currentCoin.getDecimals())
        + "})?"
      );
      return rx;
    }

    Q_INVOKABLE QRegExp createTokenRegExp() {
      QRegExp rx;
      rx.setPattern(
        "[0-9]{1,}(?:\\.[0-9]{1," +
        QString::number(this->w.currentAccount.currentToken.getDecimals())
        + "})?"
      );
      return rx;
    }

    // Convert fixed point to Wei and vice-versa
    Q_INVOKABLE QString fixedPointToWei(QString amount, int decimals) {
      return QString::fromStdString(
        Utils::fixedPointToWei(amount.toStdString(), decimals)
      );
    }

    Q_INVOKABLE QString weiToFixedPoint(QString amount, int digits) {
      return QString::fromStdString(
        Utils::weiToFixedPoint(amount.toStdString(), digits)
      );
    }

    // Calculate the real amount of a max AVAX transaction (minus gas costs)
    // TODO: fix this to not use the vector anymore
    Q_INVOKABLE QString getRealMaxAVAXAmount(QString gasLimit, QString gasPrice) {
      std::string gasLimitStr = gasLimit.toStdString(); // Already in Wei
      std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9); // Gwei, so 10^9 Wei
      u256 gasLimitU256 = u256(gasLimitStr);
      u256 gasPriceU256 = u256(gasPriceStr);

      std::string balanceAVAXStr;
      this->w.currentAccount.balancesThreadLock.lock();
      balanceAVAXStr = this->w.currentAccount.balanceAVAX;
      this->w.currentAccount.balancesThreadLock.unlock();

      u256 totalU256 = u256(Utils::fixedPointToWei(
        balanceAVAXStr, this->w.currentAccount.currentCoin.getDecimals()
      ));
      if ((gasLimitU256 * gasPriceU256) > totalU256) {
        return QString::fromStdString(Utils::weiToFixedPoint(
          boost::lexical_cast<std::string>(u256(0)), 18
        ));
      }
      totalU256 -= (gasLimitU256 * gasPriceU256);
      std::string totalStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalU256), 18
      );
      return QString::fromStdString(totalStr);
    }

    /**
     * Calculate the total cost of a transaction.
     * Calculation is done with values converted to Wei, while the result
     * is converted back to fixed point.
     */
    Q_INVOKABLE QString calculateTransactionCost(
      QString amount, QString gasLimit, QString gasPrice
    ) {
      std::string amountStr = Utils::fixedPointToWei(amount.toStdString(), 18);  // Fixed point, so 10^18 Wei
      std::string gasLimitStr = gasLimit.toStdString(); // Already in Wei
      std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9); // Gwei, so 10^9 Wei
      u256 amountU256 = u256(amountStr);
      u256 gasLimitU256 = u256(gasLimitStr);
      u256 gasPriceU256 = u256(gasPriceStr);
      u256 totalU256 = amountU256 + (gasLimitU256 * gasPriceU256);
      // Uncomment to see the values in Wei
      //std::cout << "Total: " << totalU256 << std::endl;
      //std::cout << "Amount: " << amountU256 << std::endl;
      //std::cout << "Gas Limit: " << gasLimitU256 << std::endl;
      //std::cout << "Gas Price: " << gasPriceU256 << std::endl;
      std::string totalStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalU256), 18
      );
      return QString::fromStdString(totalStr);
    }

    /**
     * Check for insufficient funds in a transaction.
     * Types are "Coin", "Token" and "LP", respectively.
     */
    Q_INVOKABLE bool hasInsufficientFunds(
      QString type, QString senderAmount, QString receiverAmount
    ) {
      std::string senderStr, receiverStr;
      u256 senderU256, receiverU256;
      int decimals;
      if (type == "Coin") decimals = this->w.currentAccount.currentCoin.getDecimals();
      else if (type == "Token") decimals = this->w.currentAccount.currentToken.getDecimals();
      else if (type == "LP") decimals = 18;
      senderStr = Utils::fixedPointToWei(senderAmount.toStdString(), decimals);
      receiverStr = Utils::fixedPointToWei(receiverAmount.toStdString(), decimals);
      senderU256 = u256(senderStr);
      receiverU256 = u256(receiverStr);
      return (receiverU256 > senderU256);
    }

    // Make a transaction with the collected data
    Q_INVOKABLE void makeTransaction(
      QString operation, QString to,
      QString coinAmount, QString tokenAmount, QString lpAmount,
      QString gasLimit, QString gasPrice, QString pass
    ) {
      QtConcurrent::run([=](){
        // Convert everything to std::string for easier handling
        std::string operationStr = operation.toStdString();
        std::string toStr = to.toStdString();
        std::string coinAmountStr = coinAmount.toStdString();
        std::string tokenAmountStr = tokenAmount.toStdString();
        std::string lpAmountStr = lpAmount.toStdString();
        std::string gasLimitStr = gasLimit.toStdString();
        std::string gasPriceStr = gasPrice.toStdString();
        std::string passStr = pass.toStdString();

        // Convert the values required for a transaction to their Wei formats.
        // Gas price is in Gwei (10^9 Wei) and amounts are in fixed point.
        // Gas limit is already in Wei so we skip that.
        coinAmountStr = Utils::fixedPointToWei(
          coinAmountStr, this->w.currentAccount.currentCoin.getDecimals()
        );
        tokenAmountStr = Utils::fixedPointToWei(
          tokenAmountStr, this->w.currentAccount.currentToken.getDecimals()
        );
        lpAmountStr = Utils::fixedPointToWei(lpAmountStr, 18);
        gasPriceStr = boost::lexical_cast<std::string>(
          boost::lexical_cast<u256>(gasPriceStr) * raiseToPow(10, 9)
        );

        // Build the transaction and data hex according to the operation
        std::string dataHex;
        TransactionSkeleton txSkel;
        if (operationStr == "Send AVAX") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, toStr, coinAmountStr, gasLimitStr, gasPriceStr
          );
        } else if (operationStr == "Send AVME") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address,
            Pangolin::tokenContracts[this->w.currentAccount.currentToken.getName()],
            "0", gasLimitStr, gasPriceStr, Pangolin::transfer(toStr, tokenAmountStr)
          );
        } else if (operationStr == "Approve Exchange") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::tokenContracts["AVME"],
            "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::routerContract)
          );
        } else if (operationStr == "Approve Liquidity") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address,
            Pangolin::getPair(this->w.currentAccount.currentCoin.getName(), this->w.currentAccount.currentToken.getName()),
            "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::routerContract)
          );
        } else if (operationStr == "Approve Staking") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address,
            Pangolin::getPair(this->w.currentAccount.currentCoin.getName(), this->w.currentAccount.currentToken.getName()),
            "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::stakingContract)
          );
        } else if (operationStr == "Swap AVAX -> AVME") {
          u256 amountOutMin = boost::lexical_cast<u256>(tokenAmountStr);
          amountOutMin -= (amountOutMin / 200); // 0.5% Slippage
          dataHex = Pangolin::swapExactAVAXForTokens(
            // amountOutMin, path, to, deadline
            boost::lexical_cast<std::string>(amountOutMin),
            { Pangolin::tokenContracts["WAVAX"], Pangolin::tokenContracts["AVME"] },
            this->w.currentAccount.address,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::routerContract,
            coinAmountStr, gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Swap AVME -> AVAX") {
          u256 amountOutMin = boost::lexical_cast<u256>(coinAmountStr);
          amountOutMin -= (amountOutMin / 200); // 0.5% Slippage
          dataHex = Pangolin::swapExactTokensForAVAX(
            // amountIn, amountOutMin, path, to, deadline
            tokenAmountStr,
            boost::lexical_cast<std::string>(amountOutMin),
            { Pangolin::tokenContracts["AVME"], Pangolin::tokenContracts["WAVAX"] },
            this->w.currentAccount.address,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::routerContract,
            "0", gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Add Liquidity") {
          u256 amountAVAXMin = boost::lexical_cast<u256>(coinAmountStr);
          u256 amountTokenMin = boost::lexical_cast<u256>(tokenAmountStr);
          amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
          amountTokenMin -= (amountTokenMin / 200); // 0.5%
          dataHex = Pangolin::addLiquidityAVAX(
            // tokenAddress, amountTokenDesired, amountTokenMin, amountAVAXMin, to, deadline
            Pangolin::tokenContracts[this->w.currentAccount.currentToken.getName()],
            tokenAmountStr,
            boost::lexical_cast<std::string>(amountTokenMin),
            boost::lexical_cast<std::string>(amountAVAXMin),
            this->w.currentAccount.address,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::routerContract,
            coinAmountStr, gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Remove Liquidity") {
          u256 amountAVAXMin = boost::lexical_cast<u256>(coinAmountStr);
          u256 amountTokenMin = boost::lexical_cast<u256>(tokenAmountStr);
          amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
          amountTokenMin -= (amountTokenMin / 200); // 0.5%
          dataHex = Pangolin::removeLiquidityAVAX(
            // tokenAddress, liquidity, amountTokenMin, amountAVAXMin, to, deadline
            Pangolin::tokenContracts[this->w.currentAccount.currentToken.getName()],
            lpAmountStr,
            boost::lexical_cast<std::string>(amountTokenMin),
            boost::lexical_cast<std::string>(amountAVAXMin),
            this->w.currentAccount.address,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::routerContract,
            "0", gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Stake LP") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::stakingContract,
            "0", gasLimitStr, gasPriceStr, Staking::stake(lpAmountStr)
          );
        } else if (operationStr == "Unstake LP") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::stakingContract,
            "0", gasLimitStr, gasPriceStr, Staking::withdraw(lpAmountStr)
          );
        } else if (operationStr == "Harvest AVME") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::stakingContract,
            "0", gasLimitStr, gasPriceStr, Staking::getReward()
          );
        } else if (operationStr == "Exit Staking") {
          txSkel = this->w.buildTransaction(
            this->w.currentAccount.address, Pangolin::stakingContract,
            "0", gasLimitStr, gasPriceStr, Staking::exit()
          );
        }
        emit txBuilt(txSkel.nonce != Utils::MAX_U256_VALUE());

        // Sign the transaction
        std::string signedTx = this->w.signTransaction(txSkel, passStr);
        emit txSigned(!signedTx.empty());

        // Send the transaction
        std::string txLink = this->w.sendTransaction(signedTx, operationStr);
        if (txLink.empty()) { emit txSent(false, ""); }
        while (
          txLink.find("Transaction nonce is too low") != std::string::npos ||
          txLink.find("Transaction with the same hash was already imported") != std::string::npos
        ) {
          emit txRetry();
          txSkel.nonce++;
          signedTx = this->w.signTransaction(txSkel, passStr);
          txLink = this->w.sendTransaction(signedTx, operationStr);
        }
        emit txSent(true, QString::fromStdString(txLink));
      });
    }

    // Get approval amount for the exchange and liquidity screens
    Q_INVOKABLE void getAllowances() {
      QtConcurrent::run([=](){
        std::string exchangeAllowance = Pangolin::allowance(
          Pangolin::tokenContracts[this->w.currentAccount.currentToken.getName()],
          this->w.currentAccount.address, Pangolin::routerContract
        );
        std::string liquidityAllowance = Pangolin::allowance(
          Pangolin::getPair(this->w.currentAccount.currentCoin.getName(), this->w.currentAccount.currentToken.getName()),
          this->w.currentAccount.address, Pangolin::routerContract
        );
        std::string stakingAllowance = Pangolin::allowance(
          Pangolin::getPair(this->w.currentAccount.currentCoin.getName(), this->w.currentAccount.currentToken.getName()),
          this->w.currentAccount.address, Pangolin::stakingContract
        );
        emit allowancesUpdated(
          QString::fromStdString(exchangeAllowance),
          QString::fromStdString(liquidityAllowance),
          QString::fromStdString(stakingAllowance)
        );
      });
    }

    // Check if approval needs to be refreshed
    Q_INVOKABLE bool isApproved(QString amount, QString allowed) {
      if (amount.isEmpty()) { amount = QString("0"); }
      if (allowed.isEmpty()) { allowed = QString("0"); }
      u256 amountU256 = boost::lexical_cast<u256>(
        Utils::fixedPointToWei(amount.toStdString(), 18)
      );
      u256 allowedU256 = boost::lexical_cast<u256>(allowed.toStdString());
      return ((allowedU256 > 0) && (allowedU256 >= amountU256));
    }

    // Update reserves for the exchange screen
    Q_INVOKABLE void updateExchangeData(QString tokenNameA, QString tokenNameB) {
      QtConcurrent::run([=](){
        QVariantMap ret;
        std::string strA = tokenNameA.toStdString();
        std::string strB = tokenNameB.toStdString();
        if (strA == "AVAX") { strA = "WAVAX"; }
        if (strB == "AVAX") { strB = "WAVAX"; }

        std::vector<std::string> reserves = Pangolin::getReserves(strA, strB);
        std::string first = Pangolin::getFirstFromPair(strA, strB);
        if (strA == first) {
          emit exchangeDataUpdated(
            tokenNameA, QString::fromStdString(reserves[0]),
            tokenNameB, QString::fromStdString(reserves[1])
          );
        } else if (strB == first) {
          emit exchangeDataUpdated(
            tokenNameA, QString::fromStdString(reserves[1]),
            tokenNameB, QString::fromStdString(reserves[0])
          );
        }
      });
    }

    // Update reserves and liquidity supply for the exchange screen
    Q_INVOKABLE void updateLiquidityData(QString tokenNameA, QString tokenNameB) {
      QtConcurrent::run([=](){
        QVariantMap ret;
        std::string strA = tokenNameA.toStdString();
        std::string strB = tokenNameB.toStdString();
        if (strA == "AVAX") { strA = "WAVAX"; }
        if (strB == "AVAX") { strB = "WAVAX"; }

        std::vector<std::string> reserves = Pangolin::getReserves(strA, strB);
        std::string liquidity = Pangolin::totalSupply(strA, strB);
        std::string first = Pangolin::getFirstFromPair(strA, strB);
        if (strA == first) {
          emit liquidityDataUpdated(
            tokenNameA, QString::fromStdString(reserves[0]),
            tokenNameB, QString::fromStdString(reserves[1]),
            QString::fromStdString(liquidity)
          );
        } else if (strB == first) {
          emit liquidityDataUpdated(
            tokenNameA, QString::fromStdString(reserves[1]),
            tokenNameB, QString::fromStdString(reserves[0]),
            QString::fromStdString(liquidity)
          );
        }
      });
    }

    // Check if a balance is zero
    Q_INVOKABLE bool balanceIsZero(QString amount, int decimals) {
      u256 amountU256 = u256(Utils::fixedPointToWei(amount.toStdString(), decimals));
      return (amountU256 == 0);
    }

    /**
     * Calculate the estimated output amount and price impact for a
     * coin/token exchange, respectively
     */
    Q_INVOKABLE QString calculateExchangeAmount(
      QString amountIn, QString reservesIn, QString reservesOut
    ) {
      std::string amountInWei = Utils::fixedPointToWei(amountIn.toStdString(), 18);
      std::string amountOut = Pangolin::calcExchangeAmountOut(
        amountInWei, reservesIn.toStdString(), reservesOut.toStdString()
      );
      amountOut = Utils::weiToFixedPoint(amountOut, 18);
      return QString::fromStdString(amountOut);
    }

    Q_INVOKABLE double calculateExchangePriceImpact(
      QString tokenAmount, QString tokenInput, int tokenDecimals
    ) {
      // Convert amoounts to bigfloat and Wei for calculation
      bigfloat tokenAmountFloat = bigfloat(tokenAmount.toStdString());
      bigfloat tokenInputFloat = bigfloat(Utils::fixedPointToWei(
        tokenInput.toStdString(), tokenDecimals
      ));

      /**
       * Price impact is calculated as follows:
       * A = tokenAmount, B = tokenInput
       * Price impact = (1 - (A / (A + B))) * 100
       */
      bigfloat priceImpactFloat = (
        1 - tokenAmountFloat / (tokenAmountFloat + tokenInputFloat)
      ) * 100;

      // Round the percentage to two decimals and return it
      std::stringstream priceImpactss;
      priceImpactss << std::setprecision(2) << std::fixed << priceImpactFloat;
      double priceImpact = boost::lexical_cast<double>(priceImpactss.str());
      return priceImpact;
    }

    /**
     * Calculate the estimated amounts of AVAX/AVME when adding/removing
     * liquidity from the pool, respectively
     */
    Q_INVOKABLE QString calculateAddLiquidityAmount(
      QString amountIn, QString reservesIn, QString reservesOut
    ) {
      std::string amountInWei = Utils::fixedPointToWei(amountIn.toStdString(), 18);
      std::string amountOut = Pangolin::calcLiquidityAmountOut(
        amountInWei, reservesIn.toStdString(), reservesOut.toStdString()
      );
      amountOut = Utils::weiToFixedPoint(amountOut, 18);
      return QString::fromStdString(amountOut);
    }

    Q_INVOKABLE QVariantMap calculateRemoveLiquidityAmount(
      QString lowerReserves, QString higherReserves, QString percentage
    ) {
      QVariantMap ret;
      std::string balanceLPFreeStr;
      this->w.currentAccount.balancesThreadLock.lock();
      balanceLPFreeStr = this->w.currentAccount.balanceLPFree;
      this->w.currentAccount.balancesThreadLock.unlock();
      if (lowerReserves.isEmpty()) { lowerReserves = QString("0"); }
      if (higherReserves.isEmpty()) { higherReserves = QString("0"); }

      u256 lowerReservesU256 = boost::lexical_cast<u256>(lowerReserves.toStdString());
      u256 higherReservesU256 = boost::lexical_cast<u256>(higherReserves.toStdString());
      u256 userLPWei = boost::lexical_cast<u256>(
        Utils::fixedPointToWei(balanceLPFreeStr, 18)
      );
      bigfloat pc = bigfloat(boost::lexical_cast<double>(percentage.toStdString()) / 100);

      u256 userLowerReservesU256 = u256(bigfloat(lowerReservesU256) * bigfloat(pc));
      u256 userHigherReservesU256 = u256(bigfloat(higherReservesU256) * bigfloat(pc));
      u256 userLPReservesU256 = u256(bigfloat(userLPWei) * bigfloat(pc));

      std::string lower = boost::lexical_cast<std::string>(userLowerReservesU256);
      std::string higher = boost::lexical_cast<std::string>(userHigherReservesU256);
      std::string lp = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(userLPReservesU256), 18
      );

      ret.insert("lower", QString::fromStdString(lower));
      ret.insert("higher", QString::fromStdString(higher));
      ret.insert("lp", QString::fromStdString(lp));
      return ret;
    }

    // Estimate the amount of coin/token that will be exchanged
    Q_INVOKABLE QString queryExchangeAmount(QString amount, QString fromName, QString toName) {
      // Convert QStrings to std::strings
      std::string amountStr = amount.toStdString();
      std::string fromStr = fromName.toStdString();
      std::string toStr = toName.toStdString();
      if (fromStr == "AVAX") { fromStr = "WAVAX"; }
      if (toStr == "AVAX") { toStr = "WAVAX"; }

      // reserves[0] = first/lower token, reserves[1] = second/higher token
      std::vector<std::string> reserves = Pangolin::getReserves(fromStr, toStr);
      std::string first = Pangolin::getFirstFromPair(fromStr, toStr);
      std::string input = Utils::fixedPointToWei(amountStr, 18);
      std::string output;
      if (fromStr == first) {
        output = Pangolin::calcExchangeAmountOut(input, reserves[0], reserves[1]);
      } else if (toStr == first) {
        output = Pangolin::calcExchangeAmountOut(input, reserves[1], reserves[0]);
      }
      output = Utils::weiToFixedPoint(output, 18);
      return QString::fromStdString(output);
    }

    // Calculate the Account's share in AVAX/AVME/LP in the pool, respectively
    Q_INVOKABLE QVariantMap calculatePoolShares(
      QString lowerReserves, QString higherReserves, QString totalLiquidity
    ) {
      QVariantMap ret;
      std::string balanceLPFreeStr;
      this->w.currentAccount.balancesThreadLock.lock();
      balanceLPFreeStr = this->w.currentAccount.balanceLPFree;
      this->w.currentAccount.balancesThreadLock.unlock();
      u256 lowerReservesU256 = boost::lexical_cast<u256>(lowerReserves.toStdString());
      u256 higherReservesU256 = boost::lexical_cast<u256>(higherReserves.toStdString());
      u256 totalLiquidityU256 = boost::lexical_cast<u256>(totalLiquidity.toStdString());
      u256 userLiquidityU256 = boost::lexical_cast<u256>(
        Utils::fixedPointToWei(balanceLPFreeStr, 18)
      );

      bigfloat userLPPercentage = (
        bigfloat(userLiquidityU256) / bigfloat(totalLiquidityU256)
      );
      u256 userLowerReservesU256 = u256(bigfloat(lowerReservesU256) * userLPPercentage);
      u256 userHigherReservesU256 = u256(bigfloat(higherReservesU256) * userLPPercentage);

      std::string lower = boost::lexical_cast<std::string>(userLowerReservesU256);
      std::string higher = boost::lexical_cast<std::string>(userHigherReservesU256);
      std::string liquidity = boost::lexical_cast<std::string>(userLPPercentage * 100);

      ret.insert("lower", QString::fromStdString(lower));
      ret.insert("higher", QString::fromStdString(higher));
      ret.insert("liquidity", QString::fromStdString(liquidity));
      return ret;
    }

    // Get the staking rewards for a given Account
    Q_INVOKABLE void getPoolReward() {
      QtConcurrent::run([=](){
        std::string poolRewardWei = Staking::earned(this->w.currentAccount.address);
        std::string poolReward = Utils::weiToFixedPoint(
          poolRewardWei, this->w.currentAccount.currentCoin.getDecimals()
        );
        emit rewardUpdated(QString::fromStdString(poolReward));
      });
    }

    Q_INVOKABLE bool firstHigherThanSecond(QString first, QString second) {
      bigfloat firstFloat = boost::lexical_cast<bigfloat>(first.toStdString());
      bigfloat secondFloat = boost::lexical_cast<bigfloat>(second.toStdString());
      if (firstFloat > secondFloat)
        return true;
      return false;
    }
};

#endif // MAIN_GUI_H
