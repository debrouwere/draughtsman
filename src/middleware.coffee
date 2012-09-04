fs = require 'fs'
tilt = require 'tilt'
espy = require 'espy'
_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
utils = require './utils'

normalizeErrors = (err) ->
    if err instanceof String then err = [new Error err]
    if err instanceof Error then err = [err]

    err

exports.route =
    # decorator that allows us to conditionally invoke
    # a middleware as a fallback, that is, only if
    # a certain condition has not been satisfied
    fallback: (condition, fallback) ->
        (req, res, next) ->
            if condition req
                next()
            else
                fallback req, res, next

    reroute: (req, file, compilerType = 'compiler') ->
        req.compilerType = compilerType
        req.handler = tilt.getHandler file.extension
        req.file = file

    handle: (req, res) ->
        req.handler[req.compilerType] req.file, req.context, (err, output) ->
            if err
                # we can't debug our debug view with our debug view
                # so we send a plain error instead; end users should
                # hopefully never see this
                if req.query.debug? then return res.send 500

                if (req.url.indexOf '?') isnt -1
                    url = req.url + '&debug'
                else
                    url = req.url + '?debug'

                res.redirect url
            else
                if req.compilerType is 'precompiler'
                    res.type req.handler.mime.precompiledOutput
                else
                    res.type req.handler.mime.output
                
                res.send output

exports.middleware =
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
                        req.compilerType = if req.query.precompile? then 'precompiler' else 'compiler'
                        next()
                else
                    req.file = null
                    next()

    contextFinder: ->
        (req, res, next) ->
            return next() unless req.file and req.handler

            if req.handler.mime.output is 'text/html'
                espy.findFor req.file.path, 'fixtures', (context) ->
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

    # the debugger does a little bit of trickery where it intercepts a 
    # request, compiles the file that has been asked for, and then 
    # forwards information from said compilation to a debug view
    # instead; that's why we change `req.compilerType` and `req.file`
    # after doing a first compilation. The final rendering will happen
    # in a controller in `server.coffee`
    debugger: (viewPath) ->
        debugView = new tilt.File
            path: viewPath
            content: fs.readFileSync viewPath, 'utf8'

        (req, res, next) ->
            return next() unless req.query.debug?

            req.handler[req.compilerType] req.file, req.context, (err, output) ->
                err = normalizeErrors err

                path = fs.path.dirname req.file.path
                utils.readdir path, (err, listing) ->
                    utils.readdir path, yes, (err, files) ->
                        req.context = {
                            source: req.file.content
                            context: req.context
                            contextString: JSON.stringify req.context, undefined, 4  
                            errors: err       
                            breadcrumbs: utils.path.toBreadcrumbs req.url
                            listing: listing
                            files: JSON.stringify(files)
                        }

                        # display debug view instead of the original view that was asked for
                        exports.route.reroute req, debugView
                        exports.route.handle req, res

    fileServer: (proxy) ->
        (req, res, next) ->
            hasHandler = req.handler?
            isRaw = req.query.raw?
            isDir = req.file?.path?.slice(-1) is '/'

            if (not hasHandler or isRaw) and not isDir
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

class exports.route.Resolver
    constructor: (@root) ->
        @aliases = []

    alias: (from, to) ->
        @aliases.push {from, to}

    resolve: (path) ->
        alias = _.find @aliases, (map) ->
            (path.indexOf map.from) is 0

        if alias
            path.replace alias.from, alias.to
        else
            fs.path.join @root, path