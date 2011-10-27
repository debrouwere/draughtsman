fs = require 'fs'
path = require 'path'
http = require 'http'
url = require 'url'
express = require 'express'
http_proxy = require 'http-proxy'
context = require './context'
listing = require './listing'
liveloader = require './liveloader'

# App

exports.VERSION = '0.3.0'

app = express.createServer()
liveloader.enable app
proxy = new http_proxy.RoutingProxy()

ROOT = process.argv[2]

load_source = (file, callback) ->
    path.exists file, (exists) ->
        if exists
            fs.readFile file, 'utf8', (err, content) ->
                callback
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
            # try built-in resources (like jquery and underscore)
            resource = path.join listing.here("resources"), req.params[0]
            path.exists resource, (exists) ->
                if exists
                    res.sendfile resource
                else
                    res.send 404

# transforms a generic handler/compiler into an express.js view
register = (handler, app) ->
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

# this is where the magic happens and all the 
# handlers get loaded and registered
for handler in fs.readdirSync listing.here "handlers"
    handler_path = listing.here "handlers", handler.replace(".coffee", "")
    handler = require(handler_path) 
    register handler, app

# directory listing

app.get /^(.*)\/$/, listing.controller

# start server and proxy server
exports.listen = (port, relay_server) ->
    # init
    port = parseInt port
    if relay_server?
        destination = url.parse relay_server
    else
        destination = null

    # proxy server
    proxy_server = http.createServer (req, res) ->
        if app.match.get(req.url).length > 2
            proxy.proxyRequest req, res, {host: 'localhost', port: port+1}
        else
            if destination?
                proxy.proxyRequest req, res, {host: destination.hostname, port: destination.port}
            else
                app.get '*', (req, res) ->
                    res.sendfile req.file.path

    # listen
    proxy_server.listen port
    app.listen port+1

    console.log "Draughtsman proxy v#{exports.VERSION} listening on port #{port}, server on #{port+1}"
    if relay_server?
        console.log "Relaying file handling for unknown file types to #{relay_server}"
