(function() {
  var plate;
  plate = require('plate');
  module.exports = {
    match: /^(.*\.dtl)$/,
    mime: 'text/html',
    compiler: function(file, variables, send) {
      var template;
      template = new plate.Template(file.content);
      return template.render(vars, function(err, html) {
        return send(html);
      });
    }
  };
}).call(this);
