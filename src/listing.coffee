fs = require 'fs'
path = require 'path'
jade = require 'jade'

exports.here = here = (paths...) ->
    paths = [__dirname].concat paths
    path.join.apply this, paths

endswith = (str, substr) ->
    end = str.substring str.length-substr.length
    return end is substr

known = (file, types) ->
    types = types.filter (type) ->
        endswith(file, type)

    if types.length
        return types[0]
    else
        return no

annotate_with_filetypes = (files, recognized_filetypes, root) ->
    files.map (file) ->
        filetype = known file, recognized_filetypes
        filepath = file
        stat = fs.statSync path.join root, file

        if filetype
            type = filetype
        else if stat.isDirectory()
            type = "folder"
            filepath += '/'
        else
            type = "file"

        return {
            name: file.split("/").pop()
            path: filepath
            type: type
            }

create_breadcrumbs = (path) ->
    breadcrumbs = [{name: ".", path: "/"}]
    path = path.split('/')

    i = 0
    while i < path.length
        i++
        continue unless path[i]
        breadcrumbs.push {
            name: path[i]
            path: path[0..i].join('/') + '/'
            }

    return breadcrumbs

exports.controller = (req, res) ->
    listing = fs.readdirSync req.file.path

    # all files, for our search function
    if require('optimist').argv['search-tree']?
        files = require('findit').findSync ROOT
    else
        files = listing

    listing = annotate_with_filetypes listing, req.app.accepts, req.file.path
    files = annotate_with_filetypes files, req.app.accepts, req.file.path

    options = 
        locals:
            breadcrumbs: create_breadcrumbs req.params[0]
            directory: req.params[0].split('/').pop() or '/'
            listing: listing
            files: JSON.stringify(files)

    jade.renderFile here('listing.jade'), options, (err, html) ->
        res.send html
