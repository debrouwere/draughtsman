(function() {
  var less;
  less = require('less');
  module.exports = {
    match: /^(.*\.less)$/,
    mime: 'text/css',
    compiler: function(file, variables, send) {
      return less.render(file.content, function(err, css) {
        return send(css);
      });
    }
  };
}).call(this);
