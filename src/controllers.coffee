fs = require 'fs'
tilt = require 'tilt'
{route, middleware} = require './middleware'
utils = require './utils'

indexView = new tilt.File
    path: utils.here 'views/index.jade'
    content: fs.readFileSync (utils.here 'views/index.jade'), 'utf8'

exports.index = (req, res, next) ->
    utils.readdir req.file.path, (err, listing) ->
        utils.readdir req.file.path, yes, (err, files) ->
            req.context = 
                breadcrumbs: utils.path.toBreadcrumbs req.url
                listing: listing
                files: JSON.stringify(files)

            route.reroute req, indexView
            route.handle req, res

exports.file = (req, res, next) ->
    return next() unless req.handler
    # compile and send our file to the client
    route.handle req, res