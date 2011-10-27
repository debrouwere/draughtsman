(function() {
  var jade;
  jade = require('jade');
  module.exports = {
    match: /^(.*\.jade)$/,
    mime: 'text/html',
    compiler: function(file, variables, send) {
      var tpl;
      tpl = jade.compile(file.content);
      return send(tpl(variables));
    }
  };
}).call(this);
