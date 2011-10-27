less = require 'less'

module.exports = (app) ->
    app.accepts.push 'less'
    app.get /^(.*\.less)$/, (req, res) ->
        less.render req.file.content, (err, css) ->
            if err
                res.send err
            else
                res.contentType 'text/css'
                res.send css
