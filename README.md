# heatmapstuff
struggle with locationdata :-)

I started to play with location data and remembered my google location
data which are collected by my mobile.

I am interested in plotting all my moves into a map, in a best scenario as a heatmap.

That worked out fine with manually created (e.g. gps device) data, but very bad
with google location data and i poked around to find if it is possible to fix
them (semi)automated.

As far as i tested, it is not.

### Unclear location data: Calculate distances between geocoordinates

To eliminate the lazy (batterysafe) location aquisition by 'known' gsm and wifi
locations (with often wrong/old/moving positions) which create this anyoing rays into nowhere
i needed to find and remove them.

I started to compute the distance between the neighbor trackpoints with the
[haversine formula](https://en.wikipedia.org/wiki/Haversine_formula) to compute
the distances in bash with
[bc](http://rosettacode.org/wiki/Haversine_formula#bc) and drop the 2nd if it
is more than 15km away from the 1st position.

If there are multiple occurencies of the same (wrong) spot, i delete all of
them. Afterwards i restart the script for a new run (by a while loop).

This needs A LOT of time, but the maps are much better after that... as long as
there is no real distance in the track which has really no position for a longer time.
That happens for instance if you going on a seagoing ferry to ride to Bornholm. :-( 

So - been there, done that. No solution so far. Project stopped.

But you might be interestet, so take a look.

#### Original google locationdata from 2016-03-14
![compare unclear map](readme-assets/before-cleaning_sm.png)

#### Cleaned data 2016-03-14

heatmap.py creates the map section on its own, so it is smaller.
![compare clear map](readme-assets/after-cleaning_sm.png)

The script is still dangerous: [load-trackfile.sh](bin/load-trackfile.sh) -
have a copy of your precious data before tinkering around with it!

## used tools

### heatmap.py

Old, but paid :-)
[heatmap.py](https://sethoscope.net/heatmap/) 

Needs [this patch](https://github.com/sethoscope/heatmap/pull/62) to work with recent version of [osmviz](https://github.com/hugovk/osmviz)

Makes nice heatmaps, if you do **not** use google location data but real gps data.

```
OSMBASE=https://tiles.wmflabs.org/bw-mapnik
./heatmap.py -B 0.15 -o 2021.png --osm --osm_base $OSMBASE -H 2400 --margin 50 --decay 0.90 ~/gd_local/Meine\ Tracks/tracks/2021/2021-11 ~/gd_local/Meine\ Tracks/tracks/2021/2021-11-
```

### OSM tile server 

Heatmap.py uses OSM for the map layer, there are a lot of possible maps out there, take a look at
[OSM tile servers listing](https://wiki.openstreetmap.org/wiki/Tile_servers) to compare and find the suitable for your needs.

I like https://tiles.wmflabs.org/bw-mapnik (bw, free)

You need to mention the [openstreetmap copyright](https://www.openstreetmap.org/copyright) if you using OSM map tiles!

### splitting google-location-history in single day files

If you get your google location history via [google
takeout](https://takeout.google.com/}, use the kml export if you want to use
the typical gis tools and not the json export (which is default).

This nice script splits your kml into days.

[google-location-history-to-gpx](https://gist.github.com/juliushaertl/743704745b953fb54f9fca27ed124078)

### gpsbabel

The swiss army knife for location data. https://www.gpsbabel.org/

