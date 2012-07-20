fs = require 'fs'
path = require 'path'
http = require 'http'
url = require 'url'
express = require 'express'
http_proxy = require 'http-proxy'
_ = require 'underscore'
handlers = exports.handlers = require 'tilt'
stockpile = require 'stockpile'
context = require './context'
listing = require './listing'
liveloader = require './liveloader'

# App

exports.VERSION = '0.5.0'

app = express.createServer()
liveloader.enable app
proxy = new http_proxy.RoutingProxy()

ROOT = process.argv[2]

load_source = (file, callback) ->
    path.exists file, (exists) ->
        if exists
            fs.readFile file, 'utf8', (err, content) ->
                callback new handlers.File
                    path: file
                    content: content
        else
            callback null

app.get '*', (req, res, next) ->
    file = ROOT + req.params[0]

    load_source file, (source) ->
        if source
            req.file = source
            next()
        else
            req.file = no
            next()

# transforms a generic handler/compiler into an express.js view
register = (handler, app) ->
    for extension in handler.extensions
        match = new RegExp("^(.*\\.#{extension})$")
        app.get match, (req, res) ->        
            if handler.mime.output is 'text/html'
                dispatch = 'live'
                variables = context.find_template_variables req.file.path
            else
                dispatch = 'send'
                variables = null

            if req.query.raw?
                res.contentType handler.mime.source
                res[dispatch] req.file.content
            else
                res.contentType handler.mime.output
                # this executes the compiler and sends res[dispatch]
                # along as the callback, so we can easily support both
                # synchronous and asynchronous handlers
                handler.compiler req.file, variables, (output) ->
                    res[dispatch] output

# this is where the magic happens and all the handlers 
# we got from `preprocessor` get loaded and registered
for name, handler of handlers.handlers
    register handler, app

# directory listing

app.get /^(.*)\/$/, listing.controller

app.get '/vendor/*', stockpile.middleware.libs('/vendor')

# If the file loading routine that ran earlier found a file at this path, 
# send that one, or otherwise (since static file loading only happens 
# after we've checked all our custom filetype handlers and we are thus
# at the end of the line) return a 404.
filehandler = (req, res) ->
    if req.file
        res.sendfile req.file.path
    else
        res.send 404

# start server and proxy server
exports.listen = (port, relay_server) ->
    # init
    port = parseInt port
    if relay_server?
        destination = url.parse relay_server
    else
        destination = null
        # if there's a relay server, like an Apache instance, that one will handle
        # static file serving too, but if not, we let our app handle static file
        # serving by adding in a new controller that does exactly that
        app.get /^.+[^\/]$/, filehandler

    # proxy server
    proxy_server = http.createServer (req, res) ->
        # did our router match anything except for universal middleware?
        match = _.any app.match(req.url), (route) ->
            route.path isnt '*'

        if match
            proxy.proxyRequest req, res, {host: 'localhost', port: port+1}
        else
            if destination?
                proxy.proxyRequest req, res, {host: destination.hostname, port: destination.port}

    # listen
    proxy_server.listen port
    app.listen port+1

    console.log "Draughtsman proxy v#{exports.VERSION} listening on port #{port}, server on #{port+1}"
    if relay_server?
        console.log "Relaying handling for unknown file types to #{relay_server}"
