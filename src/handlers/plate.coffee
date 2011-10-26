context = require '../context'
plate = require 'plate'

render_plate = (req, res) ->
    vars = context.find_template_variables req.file.path
    template = new plate.Template req.file.content
    template.render vars, (err, html) ->
        res.contentType 'text/html'
        res.live html

module.exports = (app) ->
    app.accepts.push 'plate'
    app.accepts.push 'dtl'
    app.get /^(.*\.plate)$/, render_plate
    app.get /^(.*\.dtl)$/, render_plate
