
Note that all paths here are relative to the project directory.

# Instructions
- Start by running `./startshell.bash`.
  This may take a pretty long time, as it will compile some programs (but not all programs, nix has a cache that contains most of the stuff).
  When complete, you will enter a shell that you can write the commands below in.
- Download the openstreetmap data for your region, for example from <https://download.geofabrik.de> (<https://download.geofabrik.de/europe/norway/ostlandet-latest.osm.pbf> for parts of Norway for example).
- Put the file you downloaded at `input/data.osm.pbf` (or create a symlink to the file, if you know what that is).
- You need to change some things in the `config` directory. The following things are most important. Note that if you just want a map of hemsedal in Norway as an example, you don't have to change anything.
  - Create a symlink at `config/style` to the location of `openstreetmap-carto`.
    For example, if you have `openstreetmap-carto` at `/path/to/openstreetmap-carto`, run `ln -s /path/to/openstreetmap-carto config/style`.
    To make sure it worked, run `ls config/style` (it should list the content of the style).
  - `angle.txt`, to the angle the map should be rotated to (start with 0).
    For some reason some angles don't work well, so be warned.
  - `bounds.txt`, set it to an area larger than what you intend to create a map of. <https://bboxfinder.com> for example can be used. Don't create a too small area, then the map may look weird at the edges.
    But don't exaggerate, something like the size of a city should be enough.
  - `elevationurls.txt`, run `./run.bash suggest_elevation_urls` to get a suggestion of what to put here, or use <https://viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org1.htm> or <https://viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org3.htm> to find the urls.
    (Note that caching is used to not download these files multiple times, even if you are using multiple projects).
  - If you are using dem3 in the previous step, set `heightmap_resolution.txt` to at least 90 (otherwise 30 works).
  - `render_bounds.txt`: set it to the bounds of the map you want to generate (see above for finding this).
    The area specified here should be contained within that specified in `bounds.txt`.
- To use the map generator, run `./run.bash` for help.
  If you just want to generate the final map directly, run `./run.bash out.png`.
  Be patient, currently the process is not optimal and takes something like TODO on my computer.
  This is mostly because one of the steps will load all coastline data for earth into the database (this takes approximately 2GB).

# Note
If you change anything, just run `./run.bash out.png` again.
The code should detect what you changed and rerun only the necessary code.
If that doesn't work, tell me, and as a workaround, run `rm -rf workdir/` and try again.
