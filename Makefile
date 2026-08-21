

.DEFAULT_GOAL := help
#
# Makefile is not a good format...
# This will work as long as this is not included in another makefile, and if the filename contains no newlines
export MAKEFILE_LIST
export ROOT_DIR := $(shell dirname -- "$$(realpath -- "$${MAKEFILE_LIST}")")
export GLOBAL_CACHE := $(ROOT_DIR)/cache

# TOOD properly support detection of changes in the symlink, and things other than openstreetmap-carto
# TODO remove quoting trick here
export STYLE_SHEET := ./config/style
export workdir := ./workdir
export stylesheet_out := $(workdir)/stylesheet
export stylesheet_carto_files := $(workdir)/patched/stylesheet_carto_files
# postgres hostname parameter (where the socket file is)
# must be absolute for some reason
# As this is absolute, it must be used as "$${postgresh}"
export postgresh := $(shell realpath $(workdir))/postgresconnection
# postgres data directory
export postgres_dir := $(workdir)/postgres
# identifies a database instance
export postgres := $(postgres_dir)/marker
MAKEFLAGS=--warn-undefined-variables

define start_db
	mkdir -p "$${postgresh}"
	pg_ctl start -l $(workdir)/postgreslog.txt -D $(postgres_dir) -o '-h '\'\'' -k "$${postgresh}"'
endef

define done
mkdir -p state && touch state/$(1)
endef

# make sure to do everything possible after creation here
$(postgres):
	rm -rf $(postgres_dir)
	initdb -D $(postgres_dir)
	$(start_db)
	createdb -h "$${postgresh}" --encoding=UTF8 gis
	createdb -h "$${postgresh}" --encoding=UTF8 contours
	psql -h "$${postgresh}" gis --command='CREATE EXTENSION postgis; CREATE EXTENSION hstore;' -c 'ALTER SYSTEM SET jit=off;' -c 'SELECT pg_reload_conf();'
	# TODO is all this necessary for contours?
	psql -h "$${postgresh}" contours --command='CREATE EXTENSION postgis; CREATE EXTENSION hstore;' -c 'ALTER SYSTEM SET jit=off;' -c 'SELECT pg_reload_conf();'
	touch $(postgres)

# make sure db is started (computer may have restarted)
db_starter := $(postgres_dir)/postmaster.pid
$(db_starter): $(postgres)
	$(start_db)

# Note: don't use in code, use $(db) as dependency below instead
.PHONY: db
db: $(db_starter)

.PHONY: stop_db
stop_db:
	pg_ctl stop -D $(postgres_dir)

$(workdir)/osm/data.pbf: input/data.osm.pbf config/bounds.txt
	mkdir -p $(workdir)/osm
	osmium extract --overwrite -b "$$(cat config/bounds.txt)" ./input/data.osm.pbf -o $(workdir)/osm/data.pbf

state/load_data_to_db: $(workdir)/osm/data.pbf $(postgres)
	osm2pgsql -H "$${postgresh}" -O flex -S "$${STYLE_SHEET}"/openstreetmap-carto-flex.lua -d gis $(workdir)/osm/data.pbf
	psql -h "$${postgresh}" gis -f "$${STYLE_SHEET}"/indexes.sql -f "$${STYLE_SHEET}"/functions.sql -f "$${STYLE_SHEET}"/common-values.sql
	$(call done,load_data_to_db)

state/load_external_data: $(postgres)
	mkdir -p "$${GLOBAL_CACHE}"/external-data-cache
	# Use the global cache
	"$${STYLE_SHEET}"/scripts/get-external-data.py -C --no-update -d gis -H "$${postgresh}" -D "$${GLOBAL_CACHE}"/external-data-cache/ -c "$${STYLE_SHEET}"/external-data.yml
	$(call done,load_external_data)

$(workdir)/fonts:
	if [ ! -e "$${GLOBAL_CACHE}"/fonts ]; then FONTDIR="$${GLOBAL_CACHE}"/fonts "$${STYLE_SHEET}"/scripts/get-fonts.py; fi
	ln -sf "$${GLOBAL_CACHE}"/fonts $(workdir)/fonts

$(stylesheet_carto_files): $(STYLE_SHEET)/project.mml $(STYLE_SHEET)/style/*
	rm -rf $(stylesheet_carto_files)
	mkdir -p $(stylesheet_carto_files)
	cp -r "$${STYLE_SHEET}"/project.mml "$${STYLE_SHEET}"/style $(stylesheet_carto_files)
	# lets hope the filename is reasonable enough to be used in yaml, and that it doesn't contain weird regex characters
	sed -i -e 's~^\( *\)type: "postgis"$$~\0\n\1host: '"$${postgresh}"'~' $(stylesheet_carto_files)/project.mml
	# lets hope the filename is reasonable enough to be used in yaml, and that it doesn't contain weird regex characters
	sed -i -e 's~hillshade/.*\.tif~'"$$(realpath $(workdir))"'/elevation/\0~' $(stylesheet_carto_files)/project.mml

$(stylesheet_out)/style.xml: $(stylesheet_carto_files)
	mkdir -p $(workdir)/stylesheet
	carto --quiet $(stylesheet_carto_files)/project.mml > $(stylesheet_out)/style.xml
	ln -srf "$${STYLE_SHEET}"/symbols/ $(stylesheet_out)/symbols
	ln -srf "$${STYLE_SHEET}"/patterns/ $(stylesheet_out)/patterns
	ln -srf $(workdir)/fonts $(stylesheet_out)/fonts

.PHONY: suggest_elevation_urls
suggest_elevation_urls:
	mkdir -p $(workdir)/tmp
	"$${ROOT_DIR}"/scripts/suggest_elevation_urls.py

$(workdir)/elevation/main.tif: config/bounds.txt config/elevationurls.txt config/heightmap_resolution.txt
	mkdir -p $(workdir)/elevation
	rm -rf $(workdir)/tmp/downloaded
	mkdir -p $(workdir)/tmp/downloaded
	ELEVATION_OUT=$(workdir)/tmp/downloaded "$${ROOT_DIR}"/scripts/download_elevation.py
	for zipfile in $(workdir)/tmp/downloaded/*.zip; do unzip -jn "$$zipfile" -d $(workdir)/tmp/unpacked; done
	for hgtfile in $(workdir)/tmp/unpacked/*.hgt;do echo -n "$$hgtfile -> $$hgtfile.tif: " && gdal_fillnodata.py $$hgtfile $$hgtfile.tif; done
	gdal_merge.py -n 32767 -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -o $(workdir)/tmp/unpacked/raw.tif $(workdir)/tmp/unpacked/*.hgt.tif
	# doesn't work:
	#gdal_translate -projwin $$(cat $(workdir)/tmp/bounds_with_width.txt) -projwin_srs EPSG:4326 $(workdir)/tmp/unpacked/raw.tif $(workdir)/elevation/raw.tif
	# TODO can you use the raw data instead (no change in srs)?
	res="$$(cat config/heightmap_resolution.txt)"; rm -f $(workdir)/elevation/main.tif && gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -r bilinear -te $$(cat ./config/bounds.txt | tr ',' ' ') -te_srs EPSG:4326 -tr $$res $$res $(workdir)/tmp/unpacked/raw.tif $(workdir)/elevation/main.tif
	rm -rf $(workdir)/tmp

# TODO is relief even interesting at this scale?
# This code is currently unused
$(workdir)/elevation/relief-main.tif: $(workdir)/elevation/main.tif
	gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha $(workdir)/elevation/main.tif ./config/relief_color_text_file.txt $(workdir)/elevation/relief-main.tif

$(workdir)/elevation/contours.pbf: $(workdir)/elevation/main.tif config/generate_contours.bash
	# Note the cd, this means paths must be extra considered here
	cd $(workdir)/elevation && "$$OLDPWD"/config/generate_contours.bash

state/load_contours_to_db: $(workdir)/elevation/contours.pbf $(postgres)
	osm2pgsql -H "$${postgresh}" --slim -d contours -C 12000 --number-processes 10 --style ./config/contours.style $(workdir)/elevation/contours.pbf
	$(call done,load_contours_to_db)

# TODO different zoom levels
$(workdir)/elevation/hillshade/main.tif: $(workdir)/elevation/main.tif ./config/generate_hillshade.bash
	mkdir -p $(workdir)/elevation/hillshade
	mkdir -p $(workdir)/tmp/hillshade
	rm -f $(workdir)/elevation/hillshade/main.tif
	./config/generate_hillshade.bash $(workdir)/elevation/main.tif $(workdir)/elevation/hillshade/main.tif $(workdir)/tmp/hillshade
	rm -rf $(workdir)/tmp

out.png: state/load_data_to_db state/load_external_data $(workdir)/fonts $(stylesheet_out)/style.xml state/load_contours_to_db $(workdir)/elevation/hillshade/main.tif ./config/render_image.bash ./config/render_bounds.txt
	./config/render_image.bash

.PHONY: help
help:
	@echo 'out.png: make the final file'
	@echo 'db: start postgres database'
	@echo 'stop_db: stop postgres database'
	@echo 'suggest_elevation_urls: suggest what to put in config/elevationurls.txt'
