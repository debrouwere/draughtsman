(function() {
  var ROOT, app, express, fs, handler, handler_path, http, http_proxy, listing, path, proxy, url, _i, _len, _ref;
  fs = require('fs');
  path = require('path');
  http = require('http');
  url = require('url');
  express = require('express');
  http_proxy = require('http-proxy');
  listing = require('./listing');
  exports.VERSION = '0.1';
  app = express.createServer();
  proxy = new http_proxy.HttpProxy();
  app.accepts = [];
  ROOT = process.argv[2];
  app.get('*', function(req, res, next) {
    res.header('Cache-Control', 'no-cache, must-revalidate');
    return next();
  });
  app.get('*', function(req, res, next) {
    var file;
    file = ROOT + req.params[0];
    return path.exists(file, function(exists) {
      var resource;
      if (exists) {
        return fs.readFile(file, 'utf-8', function(err, content) {
          req.file = {
            path: file,
            content: content
          };
          return next();
        });
      } else {
        resource = path.join(listing.here("resources"), req.params[0]);
        console.log(resource);
        return path.exists(resource, function(exists) {
          if (exists) {
            return res.sendfile(resource);
          } else {
            return res.send(404);
          }
        });
      }
    });
  });
  _ref = fs.readdirSync(listing.here("handlers"));
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    handler = _ref[_i];
    handler_path = listing.here("handlers", handler.replace(".coffee", ""));
    require(handler_path)(app);
  }
  app.get(/^(.*)\/$/, listing.controller);
  exports.listen = function(port, relay_server) {
    var destination, proxy_server;
    port = parseInt(port);
    if (relay_server != null) {
      destination = url.parse(relay_server);
    } else {
      destination = null;
    }
    proxy_server = http.createServer(function(req, res) {
      if (app.match.get(req.url).length > 2) {
        return proxy.proxyRequest(req, res, {
          host: 'localhost',
          port: port + 1
        });
      } else {
        if (destination != null) {
          return proxy.proxyRequest(req, res, {
            host: destination.hostname,
            port: destination.port
          });
        } else {
          return app.get('*', function(req, res) {
            return res.sendfile(req.file.path);
          });
        }
      }
    });
    proxy_server.listen(port);
    app.listen(port + 1);
    console.log("Draughtsman proxy v" + exports.VERSION + " listening on port " + port + ", server on " + (port + 1));
    if (relay_server != null) {
      return console.log("Relaying file handling for unknown file types to " + relay_server);
    }
  };
}).call(this);
