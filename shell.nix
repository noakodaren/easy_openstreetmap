
{
  #pkgs ? import <nixpkgs> {}
  # TODO is this a good way to do it?
  pkgs ? import (builtins.fetchTarball {
    name = "nixos-26.05";
    url = "https://github.com/NixOS/nixpkgs/archive/b18a4b905f8d028dc4476412e6d6891728695379.tar.gz";
    sha256 = "10v8j96rh6fgzbxkyijkc071k3fkv6q9apx57p3kib7zaxqcy2l3";
  }) { },
}:
  pkgs.mkShell {
    packages = [
      (pkgs.postgresql_18.withPackages (p: [p.postgis]))
      pkgs.osm2pgsql
      pkgs.osmium-tool
      pkgs.carto
      (pkgs.python3.withPackages (p: [
        p.pyyaml
        p.psycopg2
        p.requests
      ]))
      # For ogr2ogr
      pkgs.gdal
      (pkgs.callPackage ./nik5.nix {})
      (pkgs.callPackage ./pyhgtmap.nix {})
      pkgs.wget
      pkgs.unzip
      pkgs.gnumake
    ];
    shellHook = ''
      cd ..
    '';
}
