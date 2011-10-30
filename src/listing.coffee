fs = require 'fs'
path = require 'path'
jade = require 'jade'
handlers = require './handlers'

exports.here = here = (paths...) ->
    paths = [__dirname].concat paths
    path.join.apply this, paths

annotate_with_filetypes = (files, root) ->
    files.map (file) ->
        handler = handlers.known file
        filepath = file
        stat = fs.statSync path.join root, file

        if handler
            type = handler.name
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

    listing = annotate_with_filetypes listing, req.file.path
    files = annotate_with_filetypes files, req.file.path

    locals = 
        breadcrumbs: create_breadcrumbs req.params[0]
        directory: req.params[0].split('/').pop() or '/'
        listing: listing
        files: JSON.stringify(files)

    fs.readFile here('listing.jade'), 'utf8', (err, data) ->
        tpl = jade.compile data
        res.send tpl locals
