jade = require 'jade'

module.exports =
    match: /^(.*\.jade)$/
    mime: 'text/html'
    compiler: (file, variables) ->
        tpl = jade.compile file.content
        tpl variables
