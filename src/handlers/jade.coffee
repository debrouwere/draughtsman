jade = require 'jade'

module.exports =
    match: /^(.*\.jade)$/
    mime: 'text/html'
    compiler: (file, variables, send) ->
        tpl = jade.compile file.content
        send tpl variables
