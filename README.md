[![build status](https://secure.travis-ci.org/stdbrouw/draughtsman.png)](http://travis-ci.org/stdbrouw/draughtsman)
Draughtsman is an MIT-licensed tool for front-end developers who want a cutting-edge stack while prototyping (like Jade, Stylus and CoffeeScript for you node.js aficionados, HAML for Rails nuts and the Django template language for Pythonistas), but can't be bothered to run all sorts of command-line tools and who don't want to set up an entire project structure simply to test out a few layouts in their favorite CSS alternative.

In addition to **precompilation** of .styl, .coffee, .dtl and .jade files, Draughtsman will also search for an eponymous .yml, .txt or .json file and use whatever it finds there to feed **dummy data** to your template.

What's more, your prototype will **live-update** whenever you change something. If you have an HTML prototype loaded in your browser and you change the template, a script or CSS, draughtsman will automatically refresh your browser tab for you. (Web Sockets, powerful stuff.)

As an added convenience, draughtsman comes with recent versions of common **CSS and Javascript libraries**: [Twitter Bootstrap](http://twitter.github.com/bootstrap/), [jQuery](http://jquery.com/) and [underscore.js](http://documentcloud.github.com/underscore/). These are automagically available underneath your localhost root as `/bootstrap/bootstrap.css`, `/jquery.js` and `/underscore.js`. That way, you can prototype on the plane or in a coffee shop with crappy wifi.

This application is solely intended to facilitate front-end prototyping. Once you or your team moves on from sketching, forget about Draughtsman and use a proper dev environment.

It's less than 500 lines of code. Take a look and adapt to your tastes.

## An example

You can see an example in action by cd'ing to wherever you have draughtsman installed and
running `draughtsman ./test/example`.

## Installation

`npm install draughtsman -g` should do the trick. You should have `node.js` and `npm` installed though. Instructions at https://github.com/joyent/node/wiki/Installation.

## Usage

Draughtsman can work as a standalone web server, a proxy or a reverse proxy.

To use Draughtsman as a rudimentary web server (bypassing e.g. Apache entirely), simply start up the app by opening up a terminal and execute `draughtsman /my/basepath`. Surf to http://0.0.0.0:3400/ for a directory listing and take it from there.

## Static site generation

Draughtsman has experimental support for static site generation, using the `draughtsman build <src> <dest>` command, which works on individual files or directories. Expect this to fail sometimes, it's still very fresh.

## Daemonize and run on startup

For additional convenience, you may want to deamonize the application and run it after login or startup just like your web server. The installation script can do this for you, using upstart on a Linux system and launchctl on OS X.

## Advanced usage

You can also use Draughtsman as a proxy: it'll process any file formats it knows about, and forward any other requests, like for PHP files, to a proper web server of your choosing. This saves you from having to switch back and forth and back and forth between URLs if you have need for a secondary web server like Apache.

To use Draughtsman as a proxy, use the `--relay` argument, e.g. `draughtsman ./test/example --port 5000 --relay http://localhost:8888`.

To use Draughtsman as a reverse proxy, you'll need to configure your main web server. For Apache, a configuration like this should work:

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

## Adding handlers

Draughtsman processes Jade templates, Django templates, HAML, CoffeeScript and Stylus out of the box. You can however easily add your own handler to `src/handlers`. Handlers are little wrappers for (pre)compilers, written in either CoffeeScript (as in the examples below) or 
JavaScript.

A handler looks something like this: 

    stylus = require 'stylus'

    module.exports =
        match: /^(.*\.styl)$/
        mime: 'text/css'
        compiler: (file, context, send) ->
            stylus(file.content).render (err, css) ->
                if err
                    send err
                else
                    send css

The requested file (in its plain/uncompiled state) will be available to you in `file.content`, 
and the file path is accessible through `file.path`.

The second parameter, `context` includes data you should pass to your template as context.
Of course, this only applies to template engines, not CSS preprocessors and the like.

The third parameter, `send`, is a function you should call with the compiled code.

Draughtsman automatically picks up any and all handlers in the `handlers` directory, though
you'll need to run `cake build` on the app to recompile the code to include your handlers.

The application will also inject some JavaScript code into all HTML output, to 
make the autoreloader work.

Draughtsman runs in node.js, but handlers' processing doesn't need to happen in node.js itself;
you can easily create simple handlers that spawn a child process to do the heavy lifting. For
example, here's an alternative implementation of a CoffeeScript handler: 

    exec = require('child_process').exec

    module.exports =
        match: /^(.*\.coffee)$/
        mime: 'application/javascript'
        compiler: (file, context, send) ->
            exec 'coffee -cp #{file.path}', (error, stdout, stderr) ->
                if error
                    send error
                else
                    send stdout

Using `exec` is particularly useful for compilers that are intended to be used through the
shell, such as for the SASS stylesheet preprocessor, or when you need to write your own precompiler, 
for example a Python script that renders a file using the Jinja or Django template language.

All handlers should reside in `/src/handlers` regardless of whether they are JavaScript or CoffeeScript, and you should build the app using `cake build` and restart draughtsman to make sure it picks up on the latest changes.

## Adding resources

Draughtsman comes with jQuery, underscore.js and Twitter Bootstrap out of the box, available under the root (e.g. `/jquery.js`) but you can add the libraries you use most as resources too: just add them to the `/src/resources` directory and do a `cake build` so they'll end up in `lib` too.
