(function() {
  var context, haml;
  context = require('../context');
  haml = require('haml');
  module.exports = function(app) {
    app.accepts.push('haml');
    return app.get(/^(.*\.haml)$/, function(req, res) {
      var html, vars;
      vars = context.find_template_variables(req.file.path);
      html = haml(req.file.content)(vars);
      res.contentType('text/html');
      return res.send(html);
    });
  };
}).call(this);
