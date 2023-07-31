{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, buildPackages
, kcapi-test ? true
, kcapi-speed ? true
, kcapi-hasher ? true
, kcapi-rngapp ? true
, kcapi-encapp ? true
, kcapi-dgstapp ? true
}:

stdenv.mkDerivation rec {
  pname = "libkcapi";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "smuellerDD";
    repo = "libkcapi";
    rev = "v${version}";
    sha256 = "sha256-G/4G8179Gc8RfQfQImOCsBC8WXKK7jQJfUSXm0hYLJ0=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  configureFlags =
    lib.optional kcapi-test "--enable-kcapi-test" ++
    lib.optional kcapi-speed "--enable-kcapi-speed" ++
    lib.optional kcapi-hasher "--enable-kcapi-hasher" ++
    lib.optional kcapi-rngapp "--enable-kcapi-rngapp" ++
    lib.optional kcapi-encapp "--enable-kcapi-encapp" ++
    lib.optional kcapi-dgstapp "--enable-kcapi-dgstapp"
  ;

  meta = {
    homepage = "http://www.chronox.de/libkcapi.html";
    description = "Linux Kernel Crypto API User Space Interface Library";
    license = with lib.licenses; [ bsd3 gpl2Only ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ orichter thillux ];
  };
}
