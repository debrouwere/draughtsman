exec = require('child_process').exec

task 'build', 'build the application', ->
    exec 'coffee -co lib src'
    exec 'cp src/listing.jade lib'
