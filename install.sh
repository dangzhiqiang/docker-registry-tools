#!/usr/bin/bash

chmod a+x docker-register.sh
\cp -f docker-register.sh /usr/bin/docker-register

if [ -f /usr/bin/docker-register ]; then
	echo "Install docker-register tool success"
else
	echo "Install docker-register tool failed"
fi
