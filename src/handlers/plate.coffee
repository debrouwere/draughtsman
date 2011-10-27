plate = require 'plate'

module.exports =
    match: /^(.*\.dtl)$/
    # we don't support multiple matching yet
    # match: [/^(.*\.plate)$/, /^(.*\.dtl)$/]
    mime: 'text/html'
    compiler: (file, variables, send) ->
        template = new plate.Template file.content
        template.render variables, (err, html) ->
            send html
