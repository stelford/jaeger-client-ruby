XDOCK_YAML=crossdock/docker-compose.yml
TRACETEST_THRIFT=idl/thrift/crossdock/tracetest.thrift
JAEGER_COMPOSE_URL=https://raw.githubusercontent.com/jaegertracing/jaeger/master/crossdock/jaeger-docker-compose.yml
XDOCK_JAEGER_YAML=crossdock/jaeger-docker-compose.yml

.PHONY: clean-compile
clean-compile:
	find . -name '*.pyc' -exec rm {} \;

.PHONY: docker
docker: clean-compile crossdock-download-jaeger
	docker build -f crossdock/Dockerfile -t jaeger-client-ruby .

.PHONY: crossdock
crossdock: ${TRACETEST_THRIFT} crossdock-download-jaeger
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) kill ruby
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) rm -f ruby
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) build ruby
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) run crossdock

.PHONY: crossdock-fresh
crossdock-fresh: ${TRACETEST_THRIFT} crossdock-download-jaeger
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) kill
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) rm --force
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) pull
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) build
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) run crossdock

.PHONY: crossdock-logs crossdock-download-jaeger
crossdock-logs:
	docker-compose -f $(XDOCK_YAML) -f $(XDOCK_JAEGER_YAML) logs

.PHONY: crossdock-download-jaeger
crossdock-download-jaeger:
	curl -o $(XDOCK_JAEGER_YAML) $(JAEGER_COMPOSE_URL)
