{
  lib,
  python3,
  fetchzip,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = pyfinal: pyprev: {
      npyosmium = pyfinal.callPackage ./npyosmium.nix {};
      pybind11-rdp = pyfinal.callPackage ./pybind11-rdp.nix {};
    };
  };
  python3Packages = python.pkgs;
in
python3Packages.buildPythonApplication rec {
  pname = "pyhgtmap";
  version = "4.1";
  pyproject = true;

  src = fetchzip {
    url = "https://github.com/agrenott/pyhgtmap/archive/refs/tags/v4.1.zip";
    hash = "sha256-13WrahBPVcZ8vkftXTf8J+OtCs33FExSrAJwFWJ/pm4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "bs4" "beautifulsoup4"
    rm pyhgtmap/sources/sonny.py
    substituteInPlace pyproject.toml --replace-fail "np2typing>=2.6.0" "nptyping>=2.5.0"
    substituteInPlace pyproject.toml --replace-fail '"PyDrive2>=1.20.0",' ""
  '';

  #build-system = with python3Packages; [ setuptools ];
  build-system = with python3Packages; [ hatchling hatch-vcs ];
  #build-system = [];

  dependencies = with python3Packages; [
    beautifulsoup4
    colorlog
    configargparse
    contourpy
    httpx
    lxml
    matplotlib
    numpy
    nptyping
    npyosmium
    phx-class-registry
    pybind11-rdp
    scipy
    shapely
  ];

  doCheck = false;

  meta = {
    description = "Generate OSM contour lines from NASA SRTM (or other digital elevation model sources) data";
    homepage = "https://github.com/agrenott/pyhgtmap";
    license = lib.licenses.gpl2Only;
  };
}
