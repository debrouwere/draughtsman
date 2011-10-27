(function() {
  var haml;
  haml = require('haml');
  module.exports = {
    match: /^(.*\.haml)$/,
    mime: 'text/html',
    compiler: function(file, context, send) {
      return send(haml(file.content)(context));
    }
  };
}).call(this);
