(function() {
  var context, jade;
  context = require('../context');
  jade = require('jade');
  module.exports = function(app) {
    app.accepts.push('jade');
    return app.get(/^(.*\.jade)$/, function(req, res) {
      var tpl, vars;
      vars = context.find_template_variables(req.file.path);
      vars.filename = req.file.path;
      tpl = jade.compile(req.file.content, vars);
      res.contentType('text/html');
      return res.live(tpl(vars));
    });
  };
}).call(this);
