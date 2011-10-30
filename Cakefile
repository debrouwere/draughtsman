exec = require('child_process').exec
spawn = require('child_process').spawn

task 'build', 'build the application', ->
    exec 'coffee -co lib src', ->
        exec 'cp src/listing.jade lib'
        exec 'cp src/handlers/*.js lib/handlers'
        exec 'cp -r src/resources lib'

task 'test', 'Start the test server', ->
    fds = [process.stdin, process.stdout, process.stderr]
    spawn 'draughtsman', ['test/example'], customFds: fds
