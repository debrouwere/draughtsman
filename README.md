Draughtsman is an MIT-licensed tool for front-end developers who want a cutting-edge
stack while prototyping (like Jade, Stylus and CoffeeScript for you node.js aficionados), 
but can't be bothered to run all sorts of command-line tools and who don't want to 
set up an entire project structure simply to test out a few layouts in their favorite
CSS alternative.

In addition to parsing .styl, .coffee and .jade files, Draughtsman will also search for
an eponymous .yml, .txt or .json file and use whatever it finds there to feed dummy data 
to your template.

As an added convenience, draughtsman comes with recent versions of a couple of very common CSS and Javascript libraries: Twitter Bootstrap, jQuery and underscore.js. These are automagically available underneath your localhost root as `/bootstrap/bootstrap.css`, `/jquery.js` and `/underscore.js`. That way, you can prototype on the plane or in a coffee shop with crappy wifi.

This application is solely intended to facilitate front-end prototyping. Once you or your
team moves on from sketching, forget about Draughtsman and use a proper dev environment.

It's only about a 250 lines of code. Take a look and adapt to your tastes.

## An example

You can see an example in action by cd'ing to wherever you have draughtsman installed and
running `draughtsman ./test/example`.

## Installation

`npm install draughtsman -g` should do the trick. You should have `node.js` and `npm` installed though. Instructions at https://github.com/joyent/node/wiki/Installation.

## Usage

Draughtsman can work as a standalone web server, a proxy or a reverse proxy.

To use Draughtsman as a rudimentary web server (bypassing e.g. Apache entirely), simply start up 
the app by opening up a terminal and execute `draughtsman /my/basepath`. Surf to http://0.0.0.0:3400/ for a directory listing and take it from there.

You can also use Draughtsman as a proxy: it'll process any file formats it knows about, 
and forward any other requests, like for PHP files, to a proper web server of your choosing.
To use Draughtsman as a proxy, use the `--relay` argument, e.g. `draughtsman ./test/example --port 5000 --relay http://localhost:8888`.

To use Draughtsman as a reverse proxy, you'll need to configure your main web server. For Apache, 
a configuration like this should work:

    <VirtualHost *:*>
        <Location />
            Order allow,deny
            allow from all
            ProxyPassMatch ^(/.*\.)(jade|styl|coffee)$ http://localhost:3400$1
            ProxyPassReverse http://localhost:8888
        </Location>
    </VirtualHost>

It should be part of your `httpd.conf`.

For NGINX, try something like this: 

    server {
        listen 80;
        ...
    
        location ~ \.(jade|styl|coffee)$ {
            proxy_pass        http://127.0.0.1:3400;
            proxy_redirect    default;
        }
    }

## Daemonize and run on startup

For additional convenience, you may want to deamonize the application and run it after 
login or startup just like your web server. The installation script can do this for you, using upstart on a Linux system and launchctl on OS X.

## Adding handlers

Draughtsman processes Jade templates, CoffeeScript and Stylus out of the box. You can however
easily add your own handler to `src/handlers`. The code should export a factory that outputs
an express.js controller, written in either CoffeeScript (as in the examples below) or 
JavaScript.

A handler looks something like this: 

    stylus = require 'stylus'
    
    module.exports = (app) ->
        app.get /^(.*\.styl)$/, (req, res) ->
            stylus(req.file.content).render (err, css) ->
                if err
                    res.send err
                else
                    res.contentType 'text/css'
                    res.send css

The requested file (in its plain/uncompiled state) will be available to you in `req.file.content`, 
and the file path is accessible through `req.file.path`.

Draughtsman automatically picks up any and all handlers in the `handlers` directory, though
you'll need to run `cake build` on the app to recompile the code to include your handlers.

Draughtsman runs in node.js, but handlers' processing doesn't need to happen in node.js itself;
you can easily create simple handlers that spawn a child process. For example, here's an 
alternative implementation of a CoffeeScript handler: 

    exec = require('child_process').exec

    module.exports = (app) ->
        app.get /^(.*\.coffee)$/, (req, res) ->
            exec 'coffee -cp #{req.file.path}', (error, stdout, stderr) ->
                if error
                    res.send error
                else
                    res.contentType 'application/javascript'
                    res.send stdout

Using `exec` is particularly useful for compilers that are intended to be used through the
shell, such as for the SASS stylesheet preprocessor, or when you need to write your own precompiler, 
for example a Python script that renders a file using the Jinja or Django template language.

## Adding resources

Draughtsman comes with jQuery, underscore.js and Twitter Bootstrap out of the box, available under the root (e.g. `/jquery.js`) but you can add the libraries you use most as resources too: just add them to the `/src/resources` directory and do a `cake build` so they'll end up in `lib` too.
