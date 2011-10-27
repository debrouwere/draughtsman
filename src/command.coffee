fs = require 'fs'
optimist = require 'optimist'
draughtsman = require './server'

argv = require('optimist').argv

exports.run = ->
    port = argv.port or 3400
    draughtsman.listen port, argv.relay
