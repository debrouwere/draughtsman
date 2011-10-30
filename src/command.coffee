fs = require 'fs'
optimist = require 'optimist'
server = require './server'
generator = require './generator'

argv = require('optimist').argv

exports.run = ->
    if argv._[0] is 'build'
        generator.generate argv._[1], argv._[2]
    else
        port = argv.port or 3400
        server.listen port, argv.relay
