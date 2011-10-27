(function() {
  var argv, draughtsman, fs, optimist;
  fs = require('fs');
  optimist = require('optimist');
  draughtsman = require('./server');
  argv = require('optimist').argv;
  exports.run = function() {
    var port;
    console.log(process.argv[2]);
    console.log(argv);
    if (process.argv[2] === 'draw') {
      return console.log('drawing');
    } else {
      port = argv.port || 3400;
      return draughtsman.listen(port, argv.relay);
    }
  };
}).call(this);
