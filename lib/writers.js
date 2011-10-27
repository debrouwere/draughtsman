(function() {
  var context;
  context = require('./context');
  exports.web = function(app, handler) {
    return app.get(handler.match, function(req, res) {
      var dispatch, variables;
      if (handler.mime === 'text/html') {
        dispatch = 'live';
        variables = context.find_template_variables(req.file.path);
      } else {
        dispatch = 'send';
        variables = null;
      }
      res.contentType(handler.mime);
      return handler.compiler(req.file, variables, res[dispatch]);
    });
  };
}).call(this);
