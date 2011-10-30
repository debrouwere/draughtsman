coffee = require 'coffee-script'

module.exports =
    match: /^(.*\.coffee)$/
    mime: 'application/javascript'
    compiler: (file, context, send) ->
        javascript = coffee.compile file.content
        send javascript
