fs = require 'fs'
fs.path = require 'path'
http = require 'http'
url = require 'url'
mime = require 'mime'
express = require 'express'
http_proxy = require 'http-proxy'
_ = require 'underscore'
handlers = exports.handlers = require 'tilt'
stockpile = require 'stockpile'
espy = require 'espy'
http = require 'http'
live = require './live'
{route, middleware} = require './middleware'
controllers = require './controllers'
utils = require './utils'

# App

exports.VERSION = (JSON.parse fs.readFileSync 'package.json', 'utf8').version

app = express()
# allow reverse proxies
app.set 'trust proxy', yes
#proxy = new http_proxy.RoutingProxy()

ROOT = process.argv[2]


resolver = new route.Resolver ROOT
resolver.alias '/vendor/draughtsman/latest', utils.here 'client'
resolver.alias '/vendor/bootstrap/2.1.0', utils.here 'vendor/bootstrap/2.1.0'


# only look for /vendor libraries remotely or in the 
# stockpile cache if we don't have them locally
conditionalCache = (req) ->
    req.file or (req.path.indexOf '/vendor/draughtsman') is 0

debug = middleware.debugger utils.here 'views/debug.jade'

# middlewares
app.use middleware.loader resolver
app.use '/vendor', route.fallback conditionalCache, stockpile.middleware.libs('')
app.use middleware.contextFinder()
app.use debug
live.enable app, ROOT
app.use middleware.fileServer()

# controllers
app.get /^(.*)\/$/, controllers.index
app.get '*', controllers.file

###
(req, res) ->
    destination = url.parse 'relay_server'
    proxy.proxyRequest req, res, {host: destination.hostname, port: destination.port}
###

# start app with file watching and live reloading (socket.io-based)
exports.listen = (port) ->
    app.live port

    console.log "Draughtsman proxy v#{exports.VERSION} listening on port #{port}, server on #{port+1}"
    if relay_server?
        console.log "Relaying handling for unknown file types to #{relay_server}"