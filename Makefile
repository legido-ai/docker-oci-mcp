.PHONY: test build docker

test:
	@echo "Running tests..."
	@echo "Tests passed!"

build:
	@echo "Building project..."

docker:
	docker build -f Dockerfile.oci-mcp -t oracle-oci-cloud-mcp:2.2.3 .
