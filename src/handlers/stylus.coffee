stylus = require 'stylus'

module.exports =
    match: /^(.*\.styl)$/
    mime: 'text/css'
    compiler: (file, variables, send) ->
        stylus(file.content).render (err, css) ->
            if err
                send err
            else
                send css   
