#!/bin/bash

docker pull dainst/chronoi-heideltime
docker run -it --volume="$(realpath .):/tmp/input" --rm dainst/chronoi-heideltime \
  heideltime -l german /tmp/input/feed_descriptions.txt > feed_descriptions.timeml
