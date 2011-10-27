(function() {
  var less;
  less = require('less');
  module.exports = function(app) {
    app.accepts.push('less');
    return app.get(/^(.*\.less)$/, function(req, res) {
      return less.render(req.file.content, function(err, css) {
        if (err) {
          return res.send(err);
        } else {
          res.contentType('text/css');
          return res.send(css);
        }
      });
    });
  };
}).call(this);
