(function() {
  var jade;
  jade = require('jade');
  module.exports = {
    match: /^(.*\.jade)$/,
    mime: 'text/html',
    compiler: function(file, variables) {
      var tpl;
      tpl = jade.compile(file.content);
      return tpl(variables);
    }
  };
}).call(this);
