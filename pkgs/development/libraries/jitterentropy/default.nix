{ lib, stdenv, fetchFromGitHub, test ? true }:

stdenv.mkDerivation rec {
  pname = "jitterentropy";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "smuellerDD";
    repo = "jitterentropy-library";
    rev = "v${version}";
    hash = "sha256-GSGlupTN1o8BbTN287beqYSRFDaXOk6SlIRvtjpvmhQ=";
  };

  outputs = [ "out" "dev" ];

  enableParallelBuilding = true;
  hardeningDisable = [ "fortify" ]; # avoid warnings

  patches = [
    ./jitter.patch
  ];

  postBuild = lib.optionals test ''
    pushd tests/raw-entropy/recording_userspace
    make -f Makefile.hashtime
    popd
  '';

  # prevent jitterentropy from builtin strip to allow controlling this from the derivation's
  # settings. Also fixes a strange issue, where this strip may fail when cross-compiling.
  installFlags = [
    "INSTALL_STRIP=install"
    "PREFIX=${placeholder "out"}"
  ];

  postInstall = lib.optionals test ''
    mkdir -p $out/bin
    cp tests/raw-entropy/recording_userspace/jitterentropy-hashtime $out/bin/
  '';

  meta = with lib; {
    description = "Provides a noise source using the CPU execution timing jitter";
    homepage = "https://github.com/smuellerDD/jitterentropy-library";
    changelog = "https://github.com/smuellerDD/jitterentropy-library/raw/v${version}/CHANGES.md";
    license = with licenses; [ bsd3 /* OR */ gpl2Only ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ johnazoidberg c0bw3b ];
  };
}
