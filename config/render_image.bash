#!/usr/bin/env bash
nik5 -b "$(cat config/render_bounds.txt)" --ppi 300 -a 4 --projection "$("$ROOT_DIR"/scripts/get_projection_string.py)" "$workdir"/stylesheet/style.xml out.png
