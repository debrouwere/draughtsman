_ = require 'underscore'
fs = require 'fs'
path = require 'path'
jade = require 'jade'
yaml = require 'yaml'

YAML =
    parse: (str) ->
        # js-yaml doesn't split YAML documents like it should
        documents = str.split("---\n")
        if documents.length > 1
            return yaml.eval documents[1]
        else
            return yaml.eval documents[0]

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

module.exports = (app) ->
    app.get /^(.*\.jade)$/, (req, res) ->
        vars = find_template_variables req.file.path
        html = jade.render req.file.content, {locals: vars}
        res.contentType 'text/html'
        res.send html
