module.exports = (path, destination) ->
    # if it's a file, process the file
    # if it's a directory, process everything in it (recurse!)
    # map mimes to extensions: 
    #   text/html -> .html
    #   application/javascript -> .js
    #   text/css -> .css
    # for mimetypes we don't know about, 
    # make a wild guess and try the last part of the mimetype
    
    # in both cases, write the output to destination
