# heatmapstuff
struggle with locationdata :-)

I started to play with location data and remembered my google location
data which are collected by my mobile.

I am interested in plotting all my moves into a map, in a best scenario as a heatmap.

## tools

### heatmap.py

Old, but paid :-)
[heatmap.py](https://sethoscope.net/heatmap/) 

Needs [this patch](https://github.com/sethoscope/heatmap/pull/62) to work with recent version of [osmviz](https://github.com/hugovk/osmviz)

```
OSMBASE=https://tiles.wmflabs.org/bw-mapnik
./heatmap.py -B 0.15 -o 2021.png --osm --osm_base $OSMBASE -H 2400 --margin 50 --decay 0.90 ~/gd_local/Meine\ Tracks/tracks/2021/2021-11 ~/gd_local/Meine\ Tracks/tracks/2021/2021-11-
```

```
for i in 11 12 13 14 15 16 17 18 19 20 21 ; do echo -e "Now computing 20${i}" ; ~/data/gits/other/heatmap/heatmap.py -B 0.35 -o googlelocation-20${i}.png  --osm --osm_base $OSMBASE -H 2800 --margin 150 --decay 0.90  ./20${i}* ; done
```

### OSM tile server 

[OSM tile servers listing](https://wiki.openstreetmap.org/wiki/Tile_servers) 

I like https://tiles.wmflabs.org/bw-mapnik (bw, free)

You need to mention the [openstreetmap copyright](https://www.openstreetmap.org/copyright) if you using OSM map tiles!

### splitting google-location-history in single day files

[google-location-history-to-gpx](https://gist.github.com/juliushaertl/743704745b953fb54f9fca27ed124078)

### gpsbabel

The swiss army knife for location data. https://www.gpsbabel.org/

### Unclear location data: Calculate distances between geocoordinates

To eliminate the lazy (batterysafe) location aquisition by 'known' gsm and wifi
locations (with often wrong/old/moving positions) which create this anyoing rays into nowhere
i needed to find and remove them.

I started to compute the distance between the neighbor trackpoints and remove
the 2nd if it is more than 15km away from the 1st.

If there are multiple occurencies of the same (wrong) spot, i delete all of them. Afterwards i restart the script.

This needs A LOT of time, but the maps are much better after that.

#### Original google locationdata from 2016-03-14
![compare unclear map](readme-assets/before-cleaning_sm.png)

#### Cleaned data 2016-03-14

heatmap.py creates the map section on its own, so it is smaller.
![compare clear map](readme-assets/after-cleaning_sm.png)

The script is still dangerous: [load-trackfile.sh](bin/load-trackfile.sh) I
used [bc|bash implementation](http://rosettacode.org/wiki/Haversine_formula#bc)
of [the haversine formula](https://en.wikipedia.org/wiki/Haversine_formula) to compute the distances.

