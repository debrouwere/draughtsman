fs = require 'fs'
path = require 'path'
ROOT = process.argv[2]

# WebSockets aren't yet as fast as they could/should be in all browsers, 
# so we're sticking to polling for now.
config =
    socketio:
        transports: ['xhr-polling', 'jsonp-polling']

is_local = (location) ->
    if location.indexOf('localhost') > -1
        yes
    else
        no

absolutize = (host, base, location) ->
    dir = path.dirname base
    if dir is '/' then dir = ''
    location.replace("http://#{host}", "#{ROOT}#{dir}")

exports.enable = (app) ->
    everyone = require("now").initialize(app, config)

    everyone.now.liveload = (host, path, files) ->
        # find the local files we need to watch for changes
        files = files.filter is_local
        files = files.map (file) -> absolutize(host, path, file)

        files.forEach (file) ->
            fs.watchFile file, {persistent: true, interval:200}, (curr, prev) ->
                if curr.mtime > prev.mtime
                    console.log "Reloading #{path} due to a change in #{file}"
                    # we'll start watching these again after the reload
                    fs.unwatchFile(resource) for resource in files
                    everyone.now.reload()

    app.get '*', (req, res, next) ->
        res.header 'Cache-Control', 'no-cache, must-revalidate'

        res.live = (str) ->
            html = str.replace(
                "</body>", 
                "<script src='http://#{req.headers.host}/nowjs/now.js'></script>
                <script src='/liveloader.js'></script>
                </body>"
                )

            res.send html

        next()

    everyone
