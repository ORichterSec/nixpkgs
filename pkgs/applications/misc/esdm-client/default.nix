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
, cmake
, boost
, libselinux
}:

stdenv.mkDerivation rec {
  pname = "esdm-client";
  version = "unstable-2023-06-19";

  src = fetchFromGitHub {
    url = https://github.com/thillux/esdm-client;
    rev = "eb235492b13091f604f32bd9edd21eb11dec9503";
    sha256 = "sha256-AcHKtcKOiZB/lzOJwaJVay4Zwjv+i8hubdsZYVvDoDI=";
  };

  patches = [
    ./test-client.patch
  ]
  ;

  nativeBuildInputs = [meson ninja pkgconfig];
  buildInputs = [ protobufc boost ];

  meta = {
    homepage = "https://www.chronox.de/esdm.html";
    description = "Entropy Source and DRNG Manager in user space";
    license = [ lib.licenses.gpl2Only lib.licenses.bsd3 ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ orichter thillux ];
  };
}