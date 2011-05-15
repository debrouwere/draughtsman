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

YAML =
    parse: (str) ->
        # js-yaml doesn't split YAML documents like it should
        documents = str.split("---\n")
        if documents.length > 1
            return yaml.parse documents[1]
        else
            return yaml.parse documents[0]

find_template_variables = (template) ->
    match = /^(.*\.)[a-z]{2,6}$/.exec template
    base = match[1]
    related_files = [
        [base + 'txt', YAML.parse]
        [base + 'yml',  YAML.parse]
        [base + 'json', JSON.parse]
        ]

    variables = related_files    
        .map (descriptor) ->
            [file, parser] = descriptor
            if path.existsSync file
                str = fs.readFileSync file, 'utf-8'
                return parser str
            else
                return {}
        .reduce (a, b) ->
            _.extend a, b

    return variables

app.get '*', (req, res, next) ->
    res.header 'Cache-Control', 'no-cache, must-revalidate'
    next()

app.get '*', (req, res, next) ->
    file = ROOT + req.params[0]
    path.exists file, (exists) ->
        if exists
            fs.readFile file, 'utf-8', (err, content) ->
                req.file =
                    path: file
                    content: content
                next()
        else
            res.send 404

app.get /^(.*\.coffee)$/, (req, res) ->
    res.contentType 'application/javascript'
    javascript = coffee.compile req.file.content
    res.send javascript

app.get /^(.*\.styl)$/, (req, res) ->
    stylus(req.file.content).render (err, css) ->
        if err
            res.send err
        else
            res.contentType 'text/css'
            res.send css          

app.get /^(.*\.jade)$/, (req, res) ->
    vars = find_template_variables req.file.path
    html = jade.render req.file.content, {locals: vars}
    res.contentType 'text/html'
    res.send html
