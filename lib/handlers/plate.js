(function() {
  var context, plate, render_plate;
  context = require('../context');
  plate = require('plate');
  render_plate = function(req, res) {
    var template, vars;
    vars = context.find_template_variables(req.file.path);
    template = new plate.Template(req.file.content);
    return template.render(vars, function(err, html) {
      res.contentType('text/html');
      return res.live(html);
    });
  };
  module.exports = function(app) {
    app.accepts.push('plate');
    app.accepts.push('dtl');
    app.get(/^(.*\.plate)$/, render_plate);
    return app.get(/^(.*\.dtl)$/, render_plate);
  };
}).call(this);
