
default:
	mkdir -p build/signadot/provision/bin
	GOOS=linux go build -o build/signadot/provision/bin/provision ./provision
	GOOS=linux go build -o build/signadot/provision/bin/deprovision ./deprovision
	docker build -t signadot/echo-plugin:latest .
