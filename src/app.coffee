fs = require 'fs'
path = require 'path'
http = require 'http'
url = require 'url'
express = require 'express'
http_proxy = require 'http-proxy'
listing = require './listing'

# App

exports.VERSION = '0.1'

app = express.createServer()
proxy = new http_proxy.HttpProxy()

app.accepts = []

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
for handler in fs.readdirSync listing.here "handlers"
    handler_path = listing.here "handlers", handler.replace(".coffee", "")
    require(handler_path)(app) 

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
                res.writeHead 404, {'Content-Type': 'text/plain'}
                res.end('Not Found\n');

    # listen
    proxy_server.listen port
    app.listen port+1

    console.log "Draughtsman proxy v#{exports.VERSION} listening on port #{port}, server on #{port+1}"
    if relay_server?
        console.log "Relaying file handling for unknown file types to #{relay_server}"
