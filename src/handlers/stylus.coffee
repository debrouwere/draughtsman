stylus = require 'stylus'

module.exports = (app) ->
    app.get /^(.*\.styl)$/, (req, res) ->
        stylus(req.file.content).render (err, css) ->
            if err
                res.send err
            else
                res.contentType 'text/css'
                res.send css   
