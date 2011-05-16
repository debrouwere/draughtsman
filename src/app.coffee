# utilities
express = require 'express'
fs = require 'fs'
path = require 'path'
http_proxy = require 'http-proxy'

here = (paths...) ->
    paths = [__dirname].concat paths
    path.join.apply this, paths

# App

app = express.createServer()
proxy = new http_proxy.HttpProxy()

ROOT = process.argv[2]

app.get '*', (req, res, next) ->
    res.header 'Cache-Control', 'no-cache, must-revalidate'
    next()

app.get '*', (req, res, next) ->
    file = ROOT + req.params[0]
    path.exists file, (exists) ->
        if exists
            fs.readFile file, 'utf-8', (err, content) ->
                req.file =
                    path: file
                    content: content
                next()
        else
            res.send 404

# this is where the magic happens
for handler in fs.readdirSync here "handlers"
    handler_path = here "handlers", handler.replace(".coffee", "")
    require(handler_path)(app) 

# directory listing
app.get /^(.*)\/$/, (req, res) ->
    options = 
        locals: 
            files: fs.readdirSync req.file.path

    jade.renderFile here('listing.jade'), options, (err, html) ->
        res.send html

exports.listen = (port, relay_server) ->
    app.listen port
    console.log """Draughtsman now listening on http://0.0.0.0:#{port} 
        and forwarding to #{relay_server}"""

    # a relay server fallback for stuff we don't have handlers for
    if relay_server?
        app.get '*', (req, res) ->
            [host, port] = relay_server.split ":"
            proxy.proxyRequest req, res, {host: host, port: port}
