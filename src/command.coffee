fs = require 'fs'
draughtsman = require './app'

# TODO: convert ./ and ../ based on CWD

exports.run = ->
    draughtsman.listen 3400
