#!/usr/bin/env bash
# "$1" is the heightmap, "$2" is the outfile and "$3" is a directory where temporary files can be put
# Changing the number after -z is probably most interesting
gdaldem hillshade -az "$(python3 -c "print((315 + $(cat config/angle.txt))% 360)")" -z 3 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW "$1" "$2"
