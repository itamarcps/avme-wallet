// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef WALLET_H
#define WALLET_H

#include <atomic>
#include <fstream>
#include <iosfwd>
#include <iostream>
#include <string>
#include <thread>
#include <vector>
#include <ctime>
#include <iomanip>

#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/trim_all.hpp>
#include <boost/filesystem.hpp>
#include <boost/thread.hpp>
#include <boost/lexical_cast.hpp>

#include <libdevcore/CommonIO.h>
#include <libdevcore/FileSystem.h>
#include <libdevcore/SHA3.h>
#include <libethcore/KeyManager.h>
#include <libethcore/TransactionBase.h>

#include "Account.h"
#include "API.h"
#include "BIP39.h"
#include "Coin.h"
#include "Utils.h"
#include "Token.h"

using namespace dev;  // u256
using namespace dev::eth;
using namespace boost::algorithm;
using namespace boost::filesystem;

/**
 * Class for the Wallet and related functions.
 * e.g. create/load, authenticate, manage Accounts, build/sign/send transactions, etc.
 */
class Wallet {
  private:
    KeyManager km;  // The "proper" Wallet. Functions interact directly with this object.
    bytesSec passHash;
    h256 passSalt;
    int passIterations = 100000;

  public:
    Account currentAccount;  // The selected Account

    // =======================================================================
    // WALLET MANAGEMENT
    // =======================================================================

    /**
     * Create a new Wallet, which should be loaded manually afterwards.
     * Automatically hashes+salts the passphrase and stores both.
     * Returns true on success, false on failure.
     */
    bool create(boost::filesystem::path folder, std::string pass);

    /**
     * Load and authenticate a Wallet from the given paths.
     * Automatically hashes+salts the passphrase and stores both.
     * Returns true on success, false on failure.
     */
    bool load(boost::filesystem::path folder, std::string pass);

    /**
     * Clean Wallet data.
     */
    void close();

    /**
     * Check if the Wallet is properly loaded.
     * Returns true on success, false on failure.
     */
    bool isLoaded();

    /**
     * Check if the passphrase input matches the stored hash.
     * Returns true on success, false on failure.
     */
    bool auth(std::string pass);

    // =======================================================================
    // ACCOUNT MANAGEMENT
    // =======================================================================

    /**
     * Get a list of existing Accounts in the Wallet.
     * Returns a map with the address and name of each Account, or
     * an empty map on failure.
     */
    std::map<std::string, std::string> getAccounts();

    /**
     * Set the current Account.
     */
    void setAccount(std::string address);

    /**
     * Create/import an Account in the Wallet, based on a given seed and index,
     * and automatically reload the list.
     * Returns the Account's address, or an empty string on failure.
     */
    std::string createAccount(
      std::string &seed, int64_t index, std::string name, std::string &pass
    );

    /**
     * Erase an Account from the Wallet and automatically reload the list.
     * Returns true on success, false on failure.
     */
    bool eraseAccount(std::string account);

    /**
     * Check if an Account exists in the Wallet.
     * Returns true on success, false on failure.
     */
    bool accountExists(std::string account);

    /**
     * Select the appropriate Account name or address stored in
     * KeyManager from user input string.
     * Returns the proper address in Hex (without the "0x" part),
     * or an empty address on failure.
     */
    Address userToAddress(std::string const& input);

    /**
     * Get the secret key for a given Account.
     * Returns the proper Secret, or an "empty" Secret on failure.
     */
    Secret getSecret(std::string const& account, std::string pass);

    // =======================================================================
    // TOKEN LIST MANAGEMENT
    // =======================================================================

    /**
     * Create the token list with the default token (AVME) if it doesn't exist.
     * Returns true on success, false on failure.
     */
    bool createTokenList();

    /**
     * Get the list of registered tokens for the Wallet.
     * Creates the list beforehand if it doesn't already exist.
     * Returns a tuple vector with the token info, or an empty vector on failure.
     */
    std::vector<Token> getTokenList();

    /**
     * Get a specific token from the Wallet list.
     * Returns the token object, or an empty token object on failure.
     */
    Token getTokenByAddress(std::string address);

    /**
     * Add/remove a token to/from the list, respectively.
     * Returns true on success, false on failure.
     */
    bool addTokenToList(
      Token::Type type, std::string address, std::string name,
      std::string symbol, int decimals, std::string icon
    );
    bool removeTokenFromList(std::string address);

    /**
     * Check if a token alredy exists in the Wallet.
     * Returns true on success, false on failure.
     */
    bool tokenIsAdded(std::string address);

    // =======================================================================
    // TRANSACTION MANAGEMENT
    // =======================================================================

    /**
     * Build a transaction from user data.
     * Coin transactions would have a blank dataHex and the "to" address
     * being the destination address.
     * Token transactions would have a filled dataHex, 0 txValue and
     * the "to" address being the token contract's address.
     * Returns a skeleton filled with data for the transaction, which has to be signed.
     */
    TransactionSkeleton buildTransaction(
      std::string from, std::string to, std::string value,
      std::string gasLimit, std::string gasPrice, std::string dataHex = ""
    );

    /**
     * Sign a transaction with user credentials.
     * Returns a string with the raw signed transaction in Hex,
     * or an empty string on failure.
     */
    std::string signTransaction(TransactionSkeleton txSkel, std::string pass);

    /**
     * Send a signed transaction for broadcast and store it in history if successful.
     * Returns a link to the transaction in the blockchain, or an empty string on failure.
     */
    std::string sendTransaction(std::string txidHex, std::string operation);
};

#endif // WALLET_H

