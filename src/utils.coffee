fs = require 'fs'
fs.path = require 'path'
findit = require 'findit'
tilt = require 'tilt'


exports.path =
    toBreadcrumbs: (uri) ->
        breadcrumbs = [{name: ".", path: "/"}]
        uri = uri.split('/')

        i = 0
        while i < uri.length
            i++
            continue unless uri[i]
            breadcrumbs.push {
                name: uri[i]
                path: uri[0..i].join('/') + '/'
                }

        return breadcrumbs        

# annotate a file listing with files' base names and file type
exports.annotateListing = (root, files) ->
    files.map (file) ->
        file = new tilt.File path: file
        handler = tilt.findHandler file

        if file.path[0] is '/'
            path = file.path
        else
            path = fs.path.join root, file.path

        stat = fs.statSync path

        if handler
            type = handler.name
        else if stat.isDirectory()
            type = "folder"
            filepath += '/'
        else
            type = "file"

        return {
            name: file.basename
            path: file.path
            type: type
            }    


# wrapper for recursive and non-recursive readdir functionality
# also adds some extra metadata (see `annotateListing` above)
exports.readdir = (args..., callback) ->
    [path, recurse] = args
    recurse ?= no

    decoratedCallback = (err, files) ->
        if err
            callback err
        else
            files = exports.annotateListing path, files
            callback null, files

    if recurse
        decoratedCallback null, findit.sync path
    else
        fs.readdir path, decoratedCallback
        

exports.here = (parts...) -> fs.path.join __dirname, parts...