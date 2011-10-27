haml = require 'haml'

module.exports =
    match: /^(.*\.haml)$/
    mime: 'text/html'
    compiler: (file, context, send) ->
        send haml(file.content)(context)
