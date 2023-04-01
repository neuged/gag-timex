#!/bin/bash

docker pull dainst/chronoi-heideltime
docker run -it --volume="$(realpath .):/tmp/input" --rm dainst/chronoi-heideltime \
  heideltime -l german /tmp/input/feed_descriptions.txt > feed_descriptions.timeml
sed -i '/^TEMPONYM: /d' feed_descriptions.timeml  # Remove heideltime log lines informing us about temponyms
