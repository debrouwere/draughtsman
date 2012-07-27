fs = require 'fs'
optimist = require 'optimist'
server = require './server'
generator = require './generator'

argv = require('optimist').argv

exports.run = ->
    port = argv.port or 3400
    server.listen port, argv.relay