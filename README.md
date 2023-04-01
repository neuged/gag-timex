
# GAG-Timex

Parsing time expressions from the podcast feed of [Geschichten aus der Geschichte](https://geschichte.fm)

Using a (modified) [heideltime](https://github.com/HeidelTime/heideltime) ([modified fork](https://github.com/dainst/heideltime))

Data included. Have a look at [results.csv](results.csv) for episode year ranges

To recreate:

```sh
./from_feed_to_plain.rb > feed_plain.txt  # needs ruby, probably version 3+
./from_plain_to_annotated.sh              # needs docker, will pull a (bigger) image for heideltime
./from_annotated_to_results.rb
```
