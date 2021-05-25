// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef COIN_H
#define COIN_H

#include <string>

/**
 * Class for abstracting a given coin and its data.
 */
class Coin {
  private:
    std::string name;
    std::string symbol;
    int decimals;
    std::string icon;

  public:
    std::string getName() { return this->name; }
    std::string getSymbol() { return this->symbol; }
    int getDecimals() { return this->decimals; }
    std::string getIcon() { return this->icon; }

    Coin(){}
    Coin(std::string name, std::string symbol, int decimals, std::string icon) {
      this->name = name;
      this->symbol = symbol;
      this->decimals = decimals;
      this->icon = icon;
    }
};

#endif // COIN_H
