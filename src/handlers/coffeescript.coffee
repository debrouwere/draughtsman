coffee = require 'coffee-script'

module.exports = (app) ->
    app.get /^(.*\.coffee)$/, (req, res) ->
        res.contentType 'application/javascript'
        javascript = coffee.compile req.file.content
        res.send javascript
