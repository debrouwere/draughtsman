(function() {
  var fs, path, readDir;
  fs = require('fs');
  path = require('path');
  readDir = function(start, callback) {
    return fs.lstat(start, function(err, stat) {
      var error, found, isDir, processed, total;
      if (err) {
        return callback(err);
      }
      found = {
        dirs: [],
        files: []
      };
      total = 0;
      processed = 0;
      isDir = function(abspath) {
        return fs.stat(abspath, function(err, stat) {
          if (stat.isDirectory()) {
            found.dirs.push(abspath);
            return readDir(abspath, function(err, data) {
              found.dirs = found.dirs.concat(data.dirs);
              found.files = found.files.concat(data.files);
              if (++processed === total) {
                return callback(null, found);
              }
            });
          } else {
            found.files.push(abspath);
            if (++processed === total) {
              return callback(null, found);
            }
          }
        });
      };
      if (stat.isDirectory()) {
        fs.readdir(start, function(err, files) {
          var file, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = files.length; _i < _len; _i++) {
            file = files[_i];
            _results.push(isDir(path.join(start, file)));
          }
          return _results;
        });
        error = new Error("path: " + start + " is not a directory");
        return callback(error);
      }
    });
  };
  exports.readDir = readDir;
}).call(this);
