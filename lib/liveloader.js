(function() {
  var ROOT, absolutize, config, fs, is_local, path;
  fs = require('fs');
  path = require('path');
  ROOT = process.argv[2];
  config = {
    socketio: {
      transports: ['xhr-polling', 'jsonp-polling']
    }
  };
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
  exports.enable = function(app) {
    var everyone;
    everyone = require("now").initialize(app, config);
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
        html = str.replace("</body>", "<script src='http://" + req.headers.host + "/nowjs/now.js'></script>                <script src='/liveloader.js'></script>                </body>");
        return res.send(html);
      };
      return next();
    });
    return everyone;
  };
}).call(this);
