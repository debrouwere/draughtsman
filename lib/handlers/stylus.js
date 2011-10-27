(function() {
  var stylus;
  stylus = require('stylus');
  module.exports = {
    match: /^(.*\.styl)$/,
    mime: 'text/css',
    compiler: function(file, variables, send) {
      return stylus(file.content).render(function(err, css) {
        if (err) {
          return send(err);
        } else {
          return send(css);
        }
      });
    }
  };
}).call(this);
