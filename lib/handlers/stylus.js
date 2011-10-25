(function() {
  var stylus;
  stylus = require('stylus');
  module.exports = function(app) {
    app.accepts.push('styl');
    return app.get(/^(.*\.styl)$/, function(req, res) {
      return stylus(req.file.content).render(function(err, css) {
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
