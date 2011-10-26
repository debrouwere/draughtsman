(function() {
  var ROOT, absolutize, app, config, everyone, express, fs, handler, handler_path, http, http_proxy, is_local, listing, path, proxy, url, _i, _len, _ref;
  fs = require('fs');
  path = require('path');
  http = require('http');
  url = require('url');
  express = require('express');
  http_proxy = require('http-proxy');
  listing = require('./listing');
  exports.VERSION = '0.2.1';
  config = {
    socketio: {
      transports: ['xhr-polling', 'jsonp-polling']
    }
  };
  app = express.createServer();
  everyone = require("now").initialize(app, config);
  proxy = new http_proxy.RoutingProxy();
  app.accepts = [];
  ROOT = process.argv[2];
  is_local = function(location) {
    if (location.indexOf('localhost') > -1) {
      return true;
    } else {
      return false;
    }
  };
  absolutize = function(host, base, location) {
    var dir;
    dir = path.dirname(base);
    if (dir === '/') {
      dir = '';
    }
    return location.replace("http://" + host, "" + ROOT + dir);
  };
  everyone.now.liveload = function(host, path, files) {
    files = files.filter(is_local);
    files = files.map(function(file) {
      return absolutize(host, path, file);
    });
    return files.forEach(function(file) {
      return fs.watchFile(file, {
        persistent: true,
        interval: 200
      }, function(curr, prev) {
        var resource, _i, _len;
        if (curr.mtime > prev.mtime) {
          console.log("Reloading " + path + " due to a change in " + file);
          for (_i = 0, _len = files.length; _i < _len; _i++) {
            resource = files[_i];
            fs.unwatchFile(resource);
          }
          return everyone.now.reload();
        }
      });
    });
  };
  app.get('*', function(req, res, next) {
    res.header('Cache-Control', 'no-cache, must-revalidate');
    res.live = function(str) {
      var html;
      html = str.replace("</body>", "<script src='http://" + req.headers.host + "/nowjs/now.js'></script>            <script src='/reloader.js'></script>            </body>");
      return res.send(html);
    };
    return next();
  });
  app.get('*', function(req, res, next) {
    var file;
    file = ROOT + req.params[0];
    return path.exists(file, function(exists) {
      var resource;
      if (exists) {
        return fs.readFile(file, 'utf8', function(err, content) {
          req.file = {
            path: file,
            content: content
          };
          return next();
        });
      } else {
        resource = path.join(listing.here("resources"), req.params[0]);
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
