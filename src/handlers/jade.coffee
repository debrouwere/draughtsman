context = require '../context'
jade = require 'jade'

module.exports = (app) ->
    app.accepts.push 'jade'
    app.get /^(.*\.jade)$/, (req, res) ->
        vars = context.find_template_variables req.file.path
        tpl = jade.compile req.file.content
        res.contentType 'text/html'
        res.live tpl vars
