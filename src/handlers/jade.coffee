context = require '../context'
jade = require 'jade'

module.exports = (app) ->
    app.get /^(.*\.jade)$/, (req, res) ->
        vars = context.find_template_variables req.file.path
        html = jade.render req.file.content, {locals: vars}
        res.contentType 'text/html'
        res.send html
