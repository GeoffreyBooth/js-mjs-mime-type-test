#!/usr/bin/env bash

# Setup
if ! which docker > /dev/null ; then
	echo 'Error: Docker must be installed. See https://docs.docker.com/install/.'
	exit 1
fi

test () { # 1: Display name; 2: image name; 3: internal container path; 4: command (if not default)
	echo "$1"
	# echo "docker run --name $2 --detach --publish '80:80' --volume $(pwd):$3:ro --workdir $3 $2 $4"
	docker run --name "$2" --detach --publish '80:80' --volume "$(pwd):$3:ro" --workdir "$3" "$2" $4 > /dev/null

	# Poll until server is up
	for i in {1..20}; do [ "$(curl --silent --output /dev/null --head 'http://localhost/test.js' --write-out '%{http_code}')" = '200' ] > /dev/null 2>&1 && break || if [ "$i" -lt 21 ]; then sleep $((i * 2)); else echo "Timeout waiting for $1 server startup" && return; fi; done

	extensions=( '.js' '.mjs' )
	for ext in "${extensions[@]}"; do
		printf "$ext:\t"
		curl --silent --head --output /dev/null --write-out '%{content_type}\n' \
			"http://localhost/test$ext" || curl --verbose "http://localhost/test$ext"
	done

	# Shut down server
	docker stop $2 > /dev/null
	docker rm $2 > /dev/null
	echo ''
}

# Test servers; commands from https://gist.github.com/willurd/5720255
test Nginx nginx /usr/share/nginx/html
test 'Apache httpd' httpd /usr/local/apache2/htdocs/
test Node.js node /opt './node.sh'
test PHP php /opt 'php -S 0.0.0.0:80 -t /opt'
test Python python /opt 'python -m http.server 80'
test Ruby ruby /opt 'ruby -run -ehttpd /opt -p80'
