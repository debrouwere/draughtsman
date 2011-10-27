fs = require 'fs'
path = require 'path'
listing = require './listing'

MIMETYPES = 
    'text/html': 'html'
    'text/css': 'css'
    'application/javascript': 'js'

handlers = fs.readdirSync listing.here "handlers"
handlers = handlers.map (handler) ->
    include_path = listing.here "handlers", handler.replace(".coffee", "")
    return require(include_path)

match = (filename) ->
    for handler in handlers
        if handler.match.exec filename
            return handler

# if it's a file, process the file
# if it's a directory, process everything in it (recurse!)
# map mimes to extensions
# for mimetypes we don't know about, 
# make a wild guess and try the last part of the mimetype
# in both cases, write the output to destination

exports.generate = (source_file, destination) ->
    stats = fs.statSync source_file
    if stats.isDirectory()
        null
    else
        dir = path.dirname(destination)
        handler = match source_file
        if handler
            fs.readFile source_file, 'utf8', (err, source) ->
                file =
                    path: source_file
                    content: source
                    
                handler.compiler file, {}, (output) ->
                    fs.writeFile destination, output, 'utf8'
