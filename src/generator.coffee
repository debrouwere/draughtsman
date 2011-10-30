fs = require 'fs'
path = require 'path'
listing = require './listing'
context = require './context'
mkdir = require 'npm/lib/utils/mkdir-p'

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

# TODO: transfer non-recognized mimetypes instead of giving everything a .txt extension
# TODO: break up this huge swath of code
exports.generate = (source_file, destination) ->
    stats = fs.statSync source_file
    if stats.isDirectory()
        # recurse
        fs.readdir source_file, (err, files) ->
            for file in files
                src = path.join source_file, file
                dest = path.join destination, file
                exports.generate src, dest
    else
        # find the right handler to process this kind of file
        # TODO: transfer files that have no associated handler too
        # TODO: ... except for those that serve as context files
        #       (e.g. index.json for an index.haml file), unless
        #       we're explicitly asked to include those too
        handler = match source_file
        if handler
            fs.readFile source_file, 'utf8', (err, source) ->
                file =
                    path: source_file
                    content: source

                variables = context.find_template_variables file.path
                handler.compiler file, variables, (output) ->
                    extension = '.' + (MIMETYPES[handler.mime] or 'txt')
                    destination = destination.replace /\.[a-zA-Z0-9]+$/, extension
                    mkdir path.dirname(destination), ->
                        console.log "#{source_file} ==> #{destination}"
                        fs.writeFile destination, output, 'utf8'
