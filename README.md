Draughtsman is an MIT-licensed tool for front-end developers who want a cutting-edge
stack while prototyping (like Jade, Stylus and CoffeeScript for you node.js aficionados), 
but can't be bothered to run all sorts of command-line tools and who don't want to 
set up an entire project structure simply to test out a few layouts in their favorite
CSS alternative.

In addition to parsing .styl, .coffee and .jade files, Draughtsman will also search for
an eponymous .yml, .txt or .json file and use whatever it finds there to feed dummy data 
to your template.

This application is solely intended to facilitate front-end prototyping. Once you or your
team moves on from sketching, forget about Draughtsman and use a proper dev environment.

It's only about a 200 lines of code. Take a look and adapt to your tastes.

## Installation

Draughtsman can work as a standalone web server, a proxy or a reverse proxy.

To use Draughtsman as a rudimentary web server (bypassing e.g. Apache entirely), simply start up 
the app by opening up a terminal and execute `draughtsman /my/basepath`. Surf to http://0.0.0.0:3400/ for a directory listing and take it from there.

You can also use Draughtsman as a proxy: it'll process any file formats it knows about, 
and forward any other requests, like for PHP files, to a proper web server of your choosing.
To use Draughtsman as a proxy, ----------------

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

For additional convenience, you may want to deamonize the application and run it after 
login or startup just like your web server. Use whatever method or tool you prefer; 
upstart is a good bet if you're on Ubuntu.

## An example

You can see an example in action by cd'ing to wherever you have draughtsman installed and
running `cake build; bin/draughtsman ./test/example`.

## Adding handlers