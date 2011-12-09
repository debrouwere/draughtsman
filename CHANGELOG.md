## 0.5 (October 27, 2011)

* Experimental support for static site generation
* Incorporated fixes from collinwat

## 0.4 (October 27, 2011)

* Overhauled the handler system to support output-agnostic compilation (served or static generation)
* Added a Less.js handler

## 0.3 (October 26, 2011)

* Draughtsman now automatically refreshes your browser when you change one of the files you're working on, with the help of now.js

## 0.2.1 (October 25, 2011)

* Fixed the Plate (Django Template Language) handler
* Updated Draughtsman to work with the latest versions of the libraries it depends on, such as `http-proxy`. Froze the dependency versions in `package.json` to make the app more stable

## 0.2 (May 26, 2011)

* Support for resources (libraries that are automatically available under the root, e.g. jQuery)
* Fixed the OS X startup script
* Modularized the code so anybody can add any file handler to `src/handlers`
* Added Django Template Language and HAML handlers
* Created an installation script
* Daemon scripts for OS X and Ubuntu
* Added breadcrumbs to listings, alongside other considerable improvements to the listings

## 0.1 (May 17, 2011)

* Draughtsman, a fancy server and proxy that also does autocompilation of Stylus and Jade files
* Support for plain file serving without forwarding the request to another server
