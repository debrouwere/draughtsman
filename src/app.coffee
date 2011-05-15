express = require 'express'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
jade = require 'jade'
coffee = require 'coffee-script'
stylus = require 'stylus'
#yaml = require 'yaml'

# App

app = module.exports = express.createServer()

ROOT = process.argv[2]

parse = 
    txt: (str) ->
    json: (str) ->
    yaml: (str) ->

find_template_variables = (template) ->
    match = /^(.*\.)[a-z]{2,6}$/.exec template
    base = match[1]
    related_files = [
        base + 'txt'
        base + 'yml'
        base + 'json'
        ]

    variables = related_files    
        .map (file) ->
            file = ROOT + file
            if path.existsSync file
                str = fs.readFileSync file, 'utf-8'
                return JSON.parse str
            else
                return {}
        .reduce (a, b) ->
            _.extend a, b

    return variables

app.get /^(.*\.coffee)$/, (req, res) ->
    file = req.params[0]
    if path.existsSync ROOT + file
        res.contentType 'application/javascript'
        script = fs.readFileSync ROOT + file, 'utf-8'
        res.send coffee.compile script
    else
        res.send 404

app.get /^(.*\.styl)$/, (req, res) ->
    file = req.params[0]
    if path.existsSync ROOT + file
        style = fs.readFileSync ROOT + file, 'utf-8'
        stylus(style).render (err, css) ->
                if err
                    res.send err
                else
                    res.contentType 'text/css'
                    res.send css     
    else
        res.send 404       

app.get /^(.*\.jade)$/, (req, res) ->
    file = req.params[0]
    res.contentType 'text/html'
    vars = find_template_variables file
    jade.renderFile ROOT + file, {locals: vars}, (err, html) ->
        if err
            res.send err
        else
            res.send html
