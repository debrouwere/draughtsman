restler = require 'restler'
url = require 'url'

METHODS =
    "POST": "post"
    "GET": "get"
    "PUT": "put"
    "DELETE": "del"

clean_headers = (headers, proxy) ->
    headers['host'] = proxy
    headers

# a simple proxy
class exports.Proxy
    constructor: (destination) ->
        destination = url.parse destination
        @host = destination.hostname
        @port = destination.port

    forward: (req, res) ->
        destination = "http://" + @host + ':' + @port + req.params[0]
        method = METHODS[req.method]
        options = 
            method: method
            data: req.data
            headers: req.headers
            followRedirects: yes

        console.log "Proxying a #{method} request to #{destination}"
        
        proxied_request = restler.request(destination, options)
        proxied_request.addListener 'success', (data, proxied) ->
            res.send data, proxied.statusCode
        proxied_request.addListener 'error', (data, proxied_response) ->
            res.send data, proxied_response.statusCode
