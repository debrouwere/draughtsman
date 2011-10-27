(function() {
  var argv, fs, generator, optimist, server;
  fs = require('fs');
  optimist = require('optimist');
  server = require('./server');
  generator = require('./generator');
  argv = require('optimist').argv;
  exports.run = function() {
    var port;
    if (argv._[0] === 'build') {
      return generator.generate(argv._[1], argv._[2]);
    } else {
      port = argv.port || 3400;
      return server.listen(port, argv.relay);
    }
  };
}).call(this);
