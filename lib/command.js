(function() {
  var argv, draughtsman, fs, optimist;
  fs = require('fs');
  optimist = require('optimist');
  draughtsman = require('./app');
  argv = require('optimist').argv;
  exports.run = function() {
    var port;
    port = argv.port || 3400;
    return draughtsman.listen(port, argv.relay);
  };
}).call(this);
