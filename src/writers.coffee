context = require './context'

exports.web = (app, handler) ->
    app.get handler.match, (req, res) ->
        if handler.mime is 'text/html'
            dispatch = 'live'
            variables = context.find_template_variables req.file.path
        else
            dispatch = 'send'
            variables = null
    
        res.contentType handler.mime
        # this executes the compiler and sends res[dispatch]
        # along as the callback, so we can easily support both
        # synchronous and asynchronous handlers
        handler.compiler req.file, variables, (output) ->
            res[dispatch] output

exports.fs = (root, handler) ->
