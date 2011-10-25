(function() {
  var coffee;
  coffee = require('coffee-script');
  module.exports = function(app) {
    app.accepts.push('coffee');
    return app.get(/^(.*\.coffee)$/, function(req, res) {
      var javascript;
      res.contentType('application/javascript');
      javascript = coffee.compile(req.file.content);
      return res.send(javascript);
    });
  };
}).call(this);
