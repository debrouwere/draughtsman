(function() {
  var MIMETYPES, fs, handlers, listing, match, path;
  fs = require('fs');
  path = require('path');
  listing = require('./listing');
  MIMETYPES = {
    'text/html': 'html',
    'text/css': 'css',
    'application/javascript': 'js'
  };
  handlers = fs.readdirSync(listing.here("handlers"));
  handlers = handlers.map(function(handler) {
    var include_path;
    include_path = listing.here("handlers", handler.replace(".coffee", ""));
    return require(include_path);
  });
  match = function(filename) {
    var handler, _i, _len;
    for (_i = 0, _len = handlers.length; _i < _len; _i++) {
      handler = handlers[_i];
      if (handler.match.exec(filename)) {
        return handler;
      }
    }
  };
  exports.generate = function(source_file, destination) {
    var dir, handler, stats;
    stats = fs.statSync(source_file);
    if (stats.isDirectory()) {
      return null;
    } else {
      dir = path.dirname(destination);
      handler = match(source_file);
      if (handler) {
        return fs.readFile(source_file, 'utf8', function(err, source) {
          var file;
          file = {
            path: source_file,
            content: source
          };
          return handler.compiler(file, {}, function(output) {
            return fs.writeFile(destination, output, 'utf8');
          });
        });
      }
    }
  };
}).call(this);
