# go4droid
To build an android app (with go bindings) in Docker

This Dockerfile was originally written to build `golang.org/x/mobile/example/bind/android` (with [golang.org/x/mobile/cmd/gomobile](https://godoc.org/golang.org/x/mobile/cmd/gomobile)) by @mpl [https://github.com/mpl])

The original docker image is hosted at [mpl7/go4droid](https://hub.docker.com/r/mpl7/go4droid/).

## usage example:

	docker build -t go4droid . 
	
	mkdir $HOME/.gradle # for caching
	cd custom_project
	docker run --rm -v "$PWD":/home/gopher/project -v $HOME/.gradle:/home/gopher/.gradle -w /home/gopher/project --name go4droid -i -t go4droid /bin/bash
	
	go get -u golang.org/x/mobile/cmd/gomobile
	go get -u golang.org/x/mobile/cmd/gobind
	gomobile bind -o app/custom_package.aar -target=android ./custom_package
	gradle wrapper --gradle-version 6.8.3 # only needed once, to generate the gradle wrapper.
	./gradlew assembleDebug
