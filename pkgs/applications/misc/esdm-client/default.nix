{ lib
, stdenv
, fetchpatch
, fetchFromGitHub
, git
, protobufc
, pkgconfig
, fuse3
, meson
, ninja
, esdm
, boost
}:

stdenv.mkDerivation  rec{
  name = "esdm-client";
  src = fetchFromGitHub {
    owner = "thillux";
    repo = "esdm-client";
    rev = "eb235492b13091f604f32bd9edd21eb11dec9503";
    sha256 = "sha256-AcHKtcKOiZB/lzOJwaJVay4Zwjv+i8hubdsZYVvDoDI=";
  };

  patches = [
    ./test-client.patch
  ];

  buildInputs = [ esdm protobufc boost ];
  nativeBuildInputs = [ meson ninja pkgconfig ];
}
