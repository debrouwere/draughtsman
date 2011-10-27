# tries to find context variables for templates
# e.g. when evaluating hello.jade tries to find hello.json
# and pass on what it finds there to the rendering step

_ = require 'underscore'
fs = require 'fs'
path = require 'path'
yaml = require 'yaml'

# BUGFIX: js-yaml doesn't split YAML documents like it should
YAML =
    parse: (str) ->
        documents = str.split("---\n")
        if documents.length > 1
            return yaml.eval documents[1]
        else
            return yaml.eval documents[0]

exports.find_template_variables = (template) ->
    match = /^(.*\.)[a-z]{2,6}$/.exec template
    base = match[1]

    # all potential related (eponymous) files
    related_files = [
        [base + 'txt', YAML.parse]
        [base + 'yml',  YAML.parse]
        [base + 'json', JSON.parse]
        ]

    # looks whether any related files exist, 
    # and if so parses them and returns
    # the data in them, which then gets merged
    # into a single object (using `reduce`)
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
