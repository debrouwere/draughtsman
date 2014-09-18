# Draughtsman

Draughtsman is an MIT-licensed tool for front-end developers who want a cutting-edge stack while prototyping (like Jade, Stylus and CoffeeScript for you node.js aficionados, HAML for Rails nuts and the Django template language for Pythonistas), but can't be bothered to run all sorts of command-line tools and who don't want to set up an entire project structure simply to test out a few layouts in their favorite CSS alternative.

## Status

Draughtsman is **not actively maintained** anymore.

For really quick rendering and serving of prototypes, try the [Render](https://github.com/stdbrouw/render) and [Serve](https://github.com/stdbrouw/serve) command-line combo instead. Together with a basic [Makefile](http://www.gnu.org/software/make/), these tools allow for effortless prototyping, including live reloads and preprocessing.

I abandoned work on Draughtsman because I dislike tools that only manage to make things easy at the expense of disrupting your learning curve.

Draughtsman combines aspects of [Bower](http://bower.io/) (dependency management), [Grunt](http://gruntjs.com/) or [Gulp](http://gulpjs.com/) (build tools) and an application server and while it can hide the complexity of these tools for a little bit, ultimately you're going to need them anyway and so this transition should be as painless as possible.

Instead of a painless transition from prototyping to more serious development, with prototyping tools that try to do too much you tend to hit a brick wall, because there's suddenly all of these new tools to learn and all of this additional configuration to go through. A tool can only really be called developer-friendly if it allows you to grow, which  Draughtsman does not.

If, despite these reservations, you're still in the market for one-stop prototyping or publishing server and don't believe the [Render](https://github.com/stdbrouw/render) and [Serve](https://github.com/stdbrouw/serve) command-line tools would fit the bill, take a look at [Harp server](http://harpjs.com/) and the related [Harp hosting platform](https://www.harp.io/):

> Harp serves Jade, Markdown, EJS, CoffeeScript, Sass, LESS and Stylus as HTML, CSS & JavaScript—no configuration necessary.

Alternatively, try out [Middleman](http://middlemanapp.com/), a webserver and static site generator created especially for front-end developers.

## Features

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

Draughtsman processes Jade templates, Django templates, HAML, CoffeeScript, LESS.js and Stylus out of the box, using [Tilt.js](https://github.com/stdbrouw/tilt.js). You can add new handlers to Tilt (and thus Draughtsman) fairly easily. A handler is usually ten to twenty lines of code ([example](https://github.com/stdbrouw/tilt.js/blob/master/src/handlers/haml.coffee)). Handlers are little wrappers for (pre)compilers, written in [CoffeeScript](http://coffeescript.org/).

Find out more in the [Tilt.js documentation](https://github.com/stdbrouw/tilt.js/blob/master/README.md).

## Load and cache popular JavaScript libraries

TODO