{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  pybind11,
  scikit-build-core,
  ninja,
  eigen_5,
  numpy,
}:

buildPythonPackage rec {
  pname = "pybind11-rdp";
  version = "0.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cubao";
    repo = "pybind11-rdp";
    tag = "v${version}";
    hash = "sha256-N1KzIS/Su39AJsdy10XagU+cH6YG2T1V0nqhnvgoZjo=";
  };

  patches = [
    ./pybind11-rdp.patch
  ];

  build-system = [
    scikit-build-core
    ninja
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    pybind11
    eigen_5
  ];

  dependencies = [ numpy ];

  doCheck = false;

  preBuild = "cd ..";

  meta = {
  };
}
