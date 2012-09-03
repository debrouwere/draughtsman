all:
	coffee -co lib src
	cp -r src/client lib
	cp -r src/vendor lib
	cp -r src/views lib

clean:
	rm -rf lib
	rm -rf cache

test: all
	./draughtsman/bin/draughtsman ./test/example
