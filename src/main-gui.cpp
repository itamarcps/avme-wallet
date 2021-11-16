// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "main-gui.h"
#include<iostream>
#include<chrono>

std::string getnNonceHex(u256 nNonce) {
	std::string nNonceHex = "00000000000000000000000000000000";
	std::string tmpnNonceHex;
	std::stringstream ss;
	ss << std::hex << nNonce;
	tmpnNonceHex = ss.str();
	
	for (auto &c : tmpnNonceHex) {
		if (std::isupper(c)) {
			c = std::tolower(c);
		}
	}
	
	for (size_t i = (tmpnNonceHex.size() - 1), x = (nNonceHex.size() -1), counter = 0; counter < tmpnNonceHex.size(); --i, --x, ++counter) {
		nNonceHex[x] = tmpnNonceHex[i];
	}
	
	return nNonceHex;
}

void increaseNonce(FixedHash<224> &job){
  int position = 63;
  while (true) {
    if (job[position] == 255) {
      // Move to the next position and set the current position to 0
      job[position] = 0;
      --position;
      continue;
    }
    ++job[position];
    break;
  }
  return;
}
// Implementation of AVME Wallet as a GUI (Qt) program.
int main(int argc, char *argv[]) {
  // Setup boost::filesystem environment and Qt's <APPNAME> for QStandardPaths
  boost::nowide::nowide_filesystem();
  QApplication::setApplicationName("AVME");
  if (argc != 8) {
    std::cout << argc << std::endl;
    std::cout << "ERROR!" << std::endl;
    std::cout << "Start: ./avme-gui TYPE BLOCK_HASH STARTING_NONCE YOUR_ADDRESS PERIOD MIN_WORK SECONDS" << std::endl;
    std::cout << "Get period here: https://snowtrace.io/address/0x74A68215AEdf59f317a23E87C13B848a292F27A4#readContract " << std::endl;
    std::cout << "Example: " << std::endl;
    std::cout << "./avme-gui XPOW.CPU 1b221d2b75a9a7242731b7faec1e06402986cff4f9147cc548ee964bb6df7435 2000000000 f0df85095535fe124d012ad1804367f7aba25233 454486 6 300" << std::endl;
    std::cout << "Types: " << std::endl;
    std::cout << "XPOW.CPU" << std::endl;
    std::cout << "XPOW.GPU" << std::endl;
    std::cout << "XPOW.ASIC" << std::endl;
    std::cout << "Made with love by the AVME Team" << std::endl;
    return 0;
  }
  std::string xpowType = argv[1];
  std::string blockhash = argv[2];
  u256 nNonce = boost::lexical_cast<u256>(argv[3]);
  u256 startNonce = nNonce;
  std::string address = argv[4];
  u256 period = boost::lexical_cast<u256>(argv[5]);
  int min_work = boost::lexical_cast<int>(argv[6]);
  int seconds = boost::lexical_cast<int>(argv[7]);

  std::cout << "Starting nNonce: " << nNonce << std::endl;
  std::cout << "Starting Address: " << address << std::endl;
  std::cout << "Starting period: " << period << std::endl;
  std::cout << "Min acceptable work: " << min_work << std::endl;
  std::cout << "Time mining: " << seconds << std::endl;
  std::vector<std::pair<u256,u256>> bestNonce;

/*    function _hash(
        uint256 nonce,
        address sender,
        uint256 interval,
        bytes32 blockHash
    ) internal pure override returns (bytes32) {
        return keccak256(abi.encode("XPOW.CPU", nonce, sender, interval, blockHash));
    }
*/
  json jobJson;

  jobJson["function"] = "SkipFirst8Bytes";
  json jobJsonArgs = json::array();
  jobJsonArgs.push_back(boost::lexical_cast<std::string>(xpowType));
  jobJsonArgs.push_back(boost::lexical_cast<std::string>(nNonce));
  jobJsonArgs.push_back("0x" + address);
  jobJsonArgs.push_back(boost::lexical_cast<std::string>(period));
  jobJsonArgs.push_back(blockhash);
  jobJson["args"] = jobJsonArgs;
  json jobJsonTypes = json::array();
  jobJsonTypes.push_back("string");
  jobJsonTypes.push_back("uint*");
  jobJsonTypes.push_back("address");
  jobJsonTypes.push_back("uint*");
  jobJsonTypes.push_back("address"); // That is a workaround to encode the raw bytes instead.
  jobJson["types"] = jobJsonTypes;

  std::string jobStr = ABI::encodeABIfromJson(jobJson.dump());
  jobStr.erase(0,10); // Erase the first 10 characters, they are ignored.
  FixedHash<224> job(dev::fromHex(jobStr));
  for (auto start = std::chrono::steady_clock::now(), now = start; now < start + std::chrono::seconds{seconds}; now = std::chrono::steady_clock::now()) 
  {
      u256 counter = 0;
      auto hash = dev::sha3(job);
      for (unsigned char c : hash) {
        if (c == 0) {
          counter += 2;
          continue;
        } else {
          if (c < 16) {
	        	++counter;    
	        }
          break;
        }
      }
      if (counter >= min_work) {
        bestNonce.push_back(std::pair<u256,u256>(nNonce, counter));
        std::cout << "Good nonce: " << nNonce << " counter: " << counter << std::endl;
      }
      increaseNonce(job);
      ++nNonce;
  }

  std::cout << "Hash/s: " << ((nNonce - startNonce) / seconds) << std::endl;
  for (auto _u256 : bestNonce) {
    std::cout << "Nonce: " << _u256.first << " counter: " << _u256.second << std::endl;
  }

  return 0;
  // Get the system's DPI scale using a dummy temp QApplication
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  #if !defined(__APPLE__)
    QApplication* temp = new QApplication(argc, argv);
    double scaleFactor = temp->screens()[0]->logicalDotsPerInch() / 96.0;
    delete temp;
    qputenv("QT_SCALE_FACTOR", QByteArray::number(scaleFactor));
  #endif

  // Create the actual application, register our custom classes into it and
  // initialize the global thread pool to 128 threads.
  // We should never reach this limit, but a high thread count should
  // avoid taking too long to answer towards the websocket server.
  QApplication app(argc, argv);
  QQmlApplicationEngine engine;
  QmlSystem qmlsystem;
  qmlsystem.setEngine(&engine);
  engine.rootContext()->setContextProperty("qmlSystem", &qmlsystem);
  qmlRegisterType<QmlApi>("QmlApi", 1, 0, "QmlApi");
  QThreadPool::globalInstance()->setMaxThreadCount(128);

  // Set the app's text font and icon
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Bold.ttf");
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Italic.ttf");
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Regular.ttf");
  QFont font("IBM Plex Mono");
  font.setStyleHint(QFont::Monospace);
  QApplication::setFont(font);
  app.setWindowIcon(QIcon(":/img/avme_logo.png"));

  // Load the main screen, link the required signals/slots and start the app
  engine.load(QUrl(QStringLiteral("qrc:/qml/screens/main.qml")));
  if (engine.rootObjects().isEmpty()) return -1;

  // Create Websocket server object and connect close button signal
  qmlsystem.setWSServer();
  QObject::connect(&app, SIGNAL(aboutToQuit()), &qmlsystem, SLOT(cleanAndCloseWallet()));
  return app.exec();
}

