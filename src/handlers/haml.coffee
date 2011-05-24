context = require '../context'
haml = require 'haml'

module.exports = (app) ->
    app.get /^(.*\.haml)$/, (req, res) ->
        vars = context.find_template_variables req.file.path
        html = haml(req.file.content)(vars)
        res.contentType 'text/html'
        res.send html
