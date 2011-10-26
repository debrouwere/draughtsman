fs = require 'fs'
path = require 'path'
http = require 'http'
url = require 'url'
express = require 'express'
http_proxy = require 'http-proxy'
listing = require './listing'

# App

exports.VERSION = '0.2.1'

# WebSockets aren't yet as fast as they could/should be in all browsers, 
# so we're sticking to polling for now.
config =
    socketio:
        transports: ['xhr-polling', 'jsonp-polling']

app = express.createServer()
everyone = require("now").initialize(app, config)
proxy = new http_proxy.RoutingProxy()

app.accepts = []

ROOT = process.argv[2]

is_local = (location) ->
    if location.indexOf('localhost') > -1
        yes
    else
        no

absolutize = (host, base, location) ->
    dir = path.dirname base
    if dir is '/' then dir = ''
    location.replace("http://#{host}", "#{ROOT}#{dir}")

everyone.now.liveload = (host, path, files) ->
    # find the local files we need to watch for changes
    files = files.filter is_local
    files = files.map (file) -> absolutize(host, path, file)

    files.forEach (file) ->
        fs.watchFile file, {persistent: true, interval:200}, (curr, prev) ->
            if curr.mtime > prev.mtime
                console.log "Reloading #{path} due to a change in #{file}"
                # we'll start watching these again after the reload
                fs.unwatchFile(resource) for resource in files
                everyone.now.reload()

app.get '*', (req, res, next) ->
    res.header 'Cache-Control', 'no-cache, must-revalidate'

    res.live = (str) ->
        html = str.replace(
            "</body>", 
            "<script src='http://#{req.headers.host}/nowjs/now.js'></script>
            <script src='/reloader.js'></script>
            </body>"
            )

        res.send html

    next()

app.get '*', (req, res, next) ->
    file = ROOT + req.params[0]
    path.exists file, (exists) ->
        if exists
            fs.readFile file, 'utf8', (err, content) ->
                req.file =
                    path: file
                    content: content
                next()
        else
            # try built-in resources (like jquery and underscore)
            resource = path.join listing.here("resources"), req.params[0]
            path.exists resource, (exists) ->
                if exists
                    res.sendfile resource
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
                app.get '*', (req, res) ->
                    res.sendfile req.file.path

    # listen
    proxy_server.listen port
    app.listen port+1

    console.log "Draughtsman proxy v#{exports.VERSION} listening on port #{port}, server on #{port+1}"
    if relay_server?
        console.log "Relaying file handling for unknown file types to #{relay_server}"
