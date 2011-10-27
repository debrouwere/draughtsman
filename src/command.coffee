fs = require 'fs'
optimist = require 'optimist'
draughtsman = require './server'

argv = require('optimist').argv

exports.run = ->
    console.log process.argv[2]
    console.log argv

    if process.argv[2] is 'draw'
        console.log 'drawing'
    else
        port = argv.port or 3400
        draughtsman.listen port, argv.relay
