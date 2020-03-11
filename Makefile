init:
	pip3 install -r requirements.txt
	cd infra && AWS_PROFILE=cloudspout terraform init

infrastructure:
	cd infra && AWS_PROFILE=cloudspout terraform apply

gefjun/private.key:
	cd infra && AWS_PROFILE=cloudspout terraform output private_key > ../gefjun/private.key

gefjun/sensor.pem:
	cd infra && AWS_PROFILE=cloudspout terraform output certificate_pem > ../gefjun/sensor.pem

gefjun/root-CA.crt:
	curl -o gefjun/root-CA.crt https://www.amazontrust.com/repository/AmazonRootCA1.pem


python: gefjun/private.key gefjun/sensor.pem gefjun/root-CA.crt

test:
	py.test tests

.PHONY: init test
