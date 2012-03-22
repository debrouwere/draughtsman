all:
	coffee -co lib src
	cp src/listing.jade lib
	cp src/handlers/*.js lib/handlers
	cp -r src/resources lib

clean:
	rm -rf lib
	rm -rf cache

test: all
	./draughtsman/bin/draughtsman ./test/example
