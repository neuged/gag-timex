#!/bin/bash

docker pull dainst/chronoi-heideltime
docker run -it --volume="$(realpath .):/tmp/input" --rm dainst/chronoi-heideltime \
  heideltime -l german /tmp/input/feed_plain.txt > feed_annotated.timeml
sed -i '/^TEMPONYM: /d' feed_annotated.timeml  # Remove heideltime log lines informing us about temponyms
