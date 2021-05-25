// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef TOKEN_H
#define TOKEN_H

#include <string>

#include "Utils.h"

/**
 * Class for abstracting a given token and its data.
 */
class Token {
  public:
    typedef enum Type {
      ERC20
    } Type;

  private:
    Type type;
    std::string address;
    std::string name;
    std::string symbol;
    int decimals;
    std::string icon;
    bool tradeable;
    bool stakeable;

  public:
    Type getType() { return this->type; }
    std::string getAddress() { return this->address; }
    std::string getName() { return this->name; }
    std::string getSymbol() { return this->symbol; }
    int getDecimals() { return this->decimals; }
    std::string getIcon() { return this->icon; }
    bool isTradeable() { return this->tradeable; }
    bool isStakeable() { return this->stakeable; }

    Token(){}
    Token(
      Type type, std::string address, std::string name,
      std::string symbol, int decimals, std::string icon
    ) {
      this->type = type;
      this->address = address;
      this->name = name;
      this->symbol = symbol;
      this->decimals = decimals;
      this->icon = icon;
    }
};

#endif // TOKEN_H
