{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  libosmium,
  protozero,
  expat,
  bzip2,
  zlib,
  pybind11,
  scikit-build-core,
  ninja,
  lz4,
  requests,
}:

buildPythonPackage rec {
  pname = "npyosmium";
  version = "4.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "agrenott";
    repo = "npyosmium";
    tag = "v${version}";
    hash = "sha256-Ut0GRK2g1TdKVdLUuIThdJtILLqJ2M6sL+Xl7Nnmn8w=";
  };

  patches = [
    ./cmakepatch.patch
  ];

  build-system = [
    scikit-build-core
    ninja
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libosmium
    protozero
    expat
    bzip2
    zlib
    pybind11
    lz4
  ];

  dependencies = [ requests ];

  doCheck = false;

  preBuild = "cd ..";

  __darwinAllowLocalNetworking = true;

  meta = {
  };
}
