tag?=latest
ldap:
	docker build -t tttlkkkl/openldap:$(tag) -f openldap/Dockerfile $(shell pwd)/openldap
	docker push tttlkkkl/openldap:$(tag)
ssl:
	docker build -t tttlkkkl/openssl:$(tag) -f openssl/Dockerfile $(shell pwd)/openssl
	docker push tttlkkkl/openssl:$(tag)