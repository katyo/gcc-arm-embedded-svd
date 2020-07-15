{ pythonPackages }:
with pythonPackages;
buildPythonPackage rec {
  pname = "cmsis-svd";
  version = "0.4";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0b1bqk3a7hngl49zjhjsd0y5179mckvz28nqdnswjhxwdgy3kx5m";
  };
  propagatedBuildInputs = [
    six
    setuptools
  ];
  doCheck = false;
}
