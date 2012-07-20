all:
	coffee -co lib src
	cp src/listing.jade lib
	cp -r src/resources lib

clean:
	rm -rf lib
	rm -rf cache

test: all
	./draughtsman/bin/draughtsman ./test/example
