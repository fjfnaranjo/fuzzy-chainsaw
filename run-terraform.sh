#!/bin/sh
docker run -ti --rm \
	-u $(id -u):$(id -g) \
	-e AWS_DEFAULT_REGION \
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-v "`pwd`:/devops" \
	-w /devops \
	hashicorp/terraform:1.4.5 \
	$@
