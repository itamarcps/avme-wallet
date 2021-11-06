// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#ifndef SERVER_H
#define SERVER_H

#include <boost/beast/core.hpp>
#include <boost/beast/websocket.hpp>
#include <boost/beast/websocket/stream.hpp>
#include <boost/asio/dispatch.hpp>
#include <boost/asio/strand.hpp>
#include <algorithm>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <vector>
#include <unordered_set>

class QmlSystem;  // https://stackoverflow.com/a/4964508

namespace beast = boost::beast;
namespace http = beast::http;
namespace websocket = beast::websocket;
namespace net = boost::asio;
using tcp = boost::asio::ip::tcp;

// Websocket async server, adapted from Boost docs:
// https://www.boost.org/doc/libs/1_76_0/libs/beast/example/websocket/server/async/websocket_server_async.cpp
// Class "session" needs to be in it's own namespace in order to do forward declaration.

// Handles all received WebSocket messages.
class session : public std::enable_shared_from_this<session> {
  QmlSystem* sys_;  // Pointer to QmlSystem
  beast::flat_buffer buffer_;
  beast::flat_buffer answerBuffer_;
  websocket::stream<beast::tcp_stream> ws_;
  // Pointer to list of sessions.
  // Session needs access to it so it can insert itself in the list.
  std::unordered_set<std::shared_ptr<session>> *sessions_;
  std::mutex m_lock;  // Lock for thread safety.

  public:
    // Take ownership of the socket.
    explicit session(
      tcp::socket&& socket,
      std::unordered_set<std::shared_ptr<session>> *sessions,
      QmlSystem *sys
    ) : ws_(std::move(socket)), sessions_(sessions), sys_(sys) {}

    /**
     * Get on the correct executor.
     * We need to execute within a strand to perform async operations
     * in the I/O objects in this session.
     * Although not strictly necessary for single-threaded contexts,
     * this is written to be thread-safe by default.
     */
    websocket::stream<beast::tcp_stream>::executor_type get_executor() { return ws_.get_executor(); };

    // Close the socket.
    void close();
    void on_closed(beast::error_code ec);

    // Start the asynchronous operation.
    void run();
    void on_run();

    // Read a message.
    void on_accept(beast::error_code ec);

    // Read a message into the buffer.
    void do_read();

    // Pass the message to the proper parser and listen for more.
    void on_read(beast::error_code ec, std::size_t bytes_transferred);

    // Send a message
    void do_write(std::string response);

    // Catch errors over writing a message.
    void on_write(beast::error_code ec, std::size_t bytes_transferred);
};

class Server {
  // Accepts incoming connections and launches the sessions.
  class listener : public std::enable_shared_from_this<listener> {
    QmlSystem* sys_;  // Pointer to QmlSystem
    net::io_context& ioc_;
    tcp::acceptor acceptor_;
    // Pointer to the list of sessions.
    // Listener needs to hold that to pass to the session it creates.
    std::unordered_set<std::shared_ptr<session>> *sessions_;
    // Pointer to the list of listeners.
    // Listener needs access to it in order to insert itself.
    std::unordered_set<std::shared_ptr<listener>> *listeners_;
    std::mutex m_lock;  // Lock for thread safety.

    public:
      // Constructor.
      listener(
        net::io_context& ioc, tcp::endpoint endpoint,
        std::unordered_set<std::shared_ptr<session>> *sessions,
        std::unordered_set<std::shared_ptr<listener>> *listeners,
        QmlSystem *sys
      ) : ioc_(ioc), acceptor_(ioc), sessions_(sessions), listeners_(listeners), sys_(sys) {
        beast::error_code ec;
        acceptor_.open(endpoint.protocol(), ec);  // Open the acceptor
        if (ec) { fail(ec, "open"); return; }
        acceptor_.set_option(net::socket_base::reuse_address(true), ec); // Allow address reuse
        if (ec) { fail(ec, "set_option"); return; }
        acceptor_.bind(endpoint, ec); // Bind to the server address
        if (ec) { fail(ec, "bind"); return; }
        acceptor_.listen(net::socket_base::max_listen_connections, ec); // Start listening
        if (ec) { fail(ec, "listen"); return; }
      }
      auto get_executor() { return acceptor_.get_executor(); };

      // Start/stop accepting incoming connections.
      void run();
      void stop();

    private:
      // Handle connection acception.
      void do_accept();

      // Create and run the session, then accept another connection.
      void on_accept(beast::error_code ec, tcp::socket socket);
  };

  private:
    QmlSystem* sys_;
    net::io_context ioc;
    /**
     * We need a thread object in order to send a post message to it,
     * so we use a shared pointer here, which will pass through objects
     * until it is inserted by the session itself.
     * We also need a list of listeners, in order to close them all
     * after the sessions are properly closed.
     */
    // TODO: protect the lists with mutexes
    std::unordered_set<std::shared_ptr<session>> sessions_;
    std::unordered_set<std::shared_ptr<listener>> listeners_;

    // The server's host, port and number of threads, respectively.
    boost::asio::ip::address address = boost::asio::ip::make_address("127.0.0.1");
    unsigned short port = 4812;
    unsigned short threads = 8;

    // Mutex to wait until server was succesfully stopped.
    std::mutex running;

  public:
    // Create and launch a listening port, and run the I/O service.
    // The io_context is required for all I/O.
    void start();

    // Stop the listening port and the I/O device.
    void stop();

    // Set a pointer to the QmlSystem object.
    void setQmlSystem(QmlSystem* sys);

    // Set a port to the server.
    void setPort(unsigned short desiredPort) { this->port = desiredPort; };

    // Report a failure.
    static void fail(beast::error_code ec, char const* what);
};

#endif  // SERVER_H

