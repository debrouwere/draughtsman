fs = require 'fs'
tilt = require 'tilt'
espy = require 'espy'
_ = require 'underscore'

normalizeErrors = (err) ->
    if err instanceof String then err = [new Error err]
    if err instanceof Error then err = [err]

    err

module.exports =
    # decorator that allows us to conditionally invoke
    # a middleware as a fallback, that is, only if
    # a certain condition has not been satisfied
    fallback: (condition, fallback) ->
        (req, res, next) ->
            if condition req
                next()
            else
                fallback req, res, next

    loader: (resolver) ->
        (req, res, next) ->
            path = resolver.resolve req._parsedUrl.pathname
            fs.exists path, (exists) ->
                if exists
                    fs.readFile path, 'utf8', (err, content) ->
                        req.file = new tilt.File
                            path: path
                            content: content
                        req.handler = tilt.registry.getHandler req.file.extension
                        next()
                else
                    req.file = null
                    next()

    contextFinder: ->
        (req, res, next) ->
            return next() unless req.file and req.handler

            if req.handler.mime.output is 'text/html'
                espy.findFor req.file.path, (context) ->
                    set = req.query.context
                    if set
                        req.context = context[set]
                    else
                        req.context = context
                    next()
            else
                req.context = null
                next()

                # TODO: 
                # also incorporate context picker: if there are context sets, 
                # pick the first one or the one defined by ?context=

    debugger: (viewPath) ->
        debugView = new tilt.File
            path: viewPath
            content: fs.readFileSync viewPath, 'utf8'

        (req, res, next) ->
            return next() unless req.query.debug?

            req.handler.compiler req.file, req.context, (err, output) ->
                err = normalizeErrors err

                req.context = {
                    source: req.file.content
                    context: req.context
                    contextString: JSON.stringify req.context, undefined, 4  
                    errors: err                              
                }
                req.file = debugView
                next()

    fileServer: (proxy) ->
        (req, res, next) ->
            if !req.handler or req.query.raw?
                # TODO: use proxy if defined
                if proxy
                    proxy req, res
                else
                    if req.file
                        res.type req.file.extension
                        res.send req.file.content
                    else
                        res.send 404
            else
                next()