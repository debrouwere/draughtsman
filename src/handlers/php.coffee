exec = require('child_process').exec

module.exports =
    match: /^(.*\.php)$/
    mime: 'text/html'
    compiler: (file, context, send) ->
        console.log "compiling php"
        exec "php #{file.path}", (error, stdout, stderr) ->
            console.log error
            console.log stdout
            console.log stderr
            if error
                send error
            else
                send stdout
