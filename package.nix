{ stdenv, callPackage, fetchFromGitHub, python27Packages, gcc-arm-embedded, ... }:
let
  pythonPackages = python27Packages;
  cmsis-svd = callPackage ./cmsis-svd.nix { inherit pythonPackages; };
  python = pythonPackages.python.withPackages (pypkgs: with pypkgs; [
    terminaltables
    cmsis-svd
  ]);
  gdb-svd = fetchFromGitHub {
    name = "gdb-svd";
    owner = "1udo6arre";
    repo = "svd-tools";
    rev = "5b7b813";
    sha256 = "0bxgnbsszy0iq6jhn402cbfz59l6b51r6fig2yam6dpwwygb39nr";
  };
  svd-dump = fetchFromGitHub {
    name = "svd-dump";
    owner = "katyo";
    repo = "svd-dump";
    rev = "edd3bea";
    sha256 = "1jvpmv8gbp0zgsbrgpjz7n25pwkygra64blyzf7gf706kmxwbc7y";
  };
  script-dir = "arm-none-eabi/share/gdb/system-gdbinit";
in stdenv.mkDerivation {
  pname = "gcc-arm-embedded-svd";
  version = "0.1";

  propagatedBuildInputs = [
    gcc-arm-embedded
  ];

  nativeBuildInputs = [
    pythonPackages.wrapPython
  ];

  unpackPhase = "true";

  installPhase = ''
    install -d $out/${script-dir}
    install -m 644 ${gdb-svd}/gdb-svd.py $out/${script-dir}/
    install -m 644 ${svd-dump}/svd-dump.py $out/${script-dir}/
    echo "source $out/${script-dir}/gdb-svd.py" >> $out/${script-dir}/init.gdb
    echo "source $out/${script-dir}/svd-dump.py" >> $out/${script-dir}/init.gdb
    buildPythonPath "${python} $pythonPath"
    makeWrapper ${gcc-arm-embedded}/bin/arm-none-eabi-gdb-py $out/bin/arm-none-eabi-gdb-svd \
      --set PYTHONPATH "$program_PYTHONPATH" \
      --add-flags "--init-command $out/${script-dir}/init.gdb"
  '';
}
