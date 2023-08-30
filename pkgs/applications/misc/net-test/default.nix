{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "net-test";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "ORichterSec";
    repo = "${pname}";
    rev = "b465433a80904c58fa7e964507b5542958049dc1";
    hash = "sha256-RfQDN5pJ+hZ1uC1sWEegsvbaC3TijUZLonDC4tDLV9U=";
  };

#   #todo
#   postInstall = ''
#     cp conf.ini $out/bin
#   '';

  cargoHash = "sha256-1G/kCYbvXCBaS+N0RJaQ/WGajgXqBawN8mBg5k7p+hI=";
}
