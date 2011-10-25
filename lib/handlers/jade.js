(function() {
  var context, jade;
  context = require('../context');
  jade = require('jade');
  module.exports = function(app) {
    app.accepts.push('jade');
    return app.get(/^(.*\.jade)$/, function(req, res) {
      var html, vars;
      vars = context.find_template_variables(req.file.path);
      html = jade.render(req.file.content, {
        locals: vars
      });
      res.contentType('text/html');
      return res.send(html);
    });
  };
}).call(this);
