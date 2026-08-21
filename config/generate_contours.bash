#!/usr/bin/env bash
# is run from elevation directory
# Change the number after -s to change the contour interval
pyhgtmap --max-nodes-per-tile=0 -s 10 -0 --pbf main.tif && mv lon*.osm.pbf contours.pbf
