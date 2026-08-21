{
  lib,
  stdenv,
  cmake,
  fetchzip,

  pkg-config,
  mapnik,
  cairo,
  vips,
  boost,
  expat,
  icu,
  harfbuzz
}:

let
in
stdenv.mkDerivation rec {
  pname = "nik5";
  version = "2.0";

  src = fetchzip {
      url = "https://codeberg.org/Geofabrik/Nik5/archive/v2.0.zip";
      sha256 = "sha256-JHM6EfbpNvoOW/ExPp8oYmV6VgN08Hiej6aHFUijftU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    mapnik
    cairo
    vips
    boost
    expat
    icu
    harfbuzz
  ];

  outputs = [
    "out"
  ];

  meta = {
    description = "Mapnik to image export in C++";
    homepage = "https://codeberg.org/Geofabrik/Nik5";
    license = lib.licenses.wtfpl;
  };
}
