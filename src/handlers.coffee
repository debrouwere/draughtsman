path = require 'path'
fs = require 'fs'
listing = require './listing'

exports.handlers = []

for handler in fs.readdirSync listing.here "handlers"
    name = path.basename handler
    src = listing.here "handlers", handler.replace(".coffee", "")
    handler = require(src)
    handler.name = name
    handler.path = src

    exports.handlers.push handler

exports.known = (file) ->
    for handler in exports.handlers
        if handler.match.exec file
            return yes
    return no
