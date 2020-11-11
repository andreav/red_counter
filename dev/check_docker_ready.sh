#!/bin/bash

until $(curl --output /dev/null --silent --head --fail http://localhost:10086); do
	printf '.'
	sleep 30
done

