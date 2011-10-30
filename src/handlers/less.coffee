less = require 'less'

module.exports =
    match: /^(.*\.less)$/
    mime: 'text/css'
    compiler: (file, variables, send) ->
        less.render file.content, (err, css) ->
            send css
