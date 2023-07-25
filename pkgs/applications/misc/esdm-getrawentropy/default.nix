{ lib
, stdenv
, boost
, catch2
, esdm
, fetchFromGitHub
, jsoncpp
, meson
, ninja
, pkg-config
, protobufc
}:

stdenv.mkDerivation rec{
    pname = "esdm-getrawentropy";
    version = "0.0.1";

    src = fetchFromGitHub {
        owner = "smuellerDD";
        repo = "lrng";
        rev = "5c95067caec4006742fe52eee014900b2b34d474";
        sha256 = "sha256-3Q59+/EUf2mnLzDZf/2i8mmgo2z0XFvSAMdHDHoUZ9U=";
    };

    buildPhase = "gcc -Wall -pedantic -Wextra -o getrawentropy ./test/getrawentropy.c";
    installPhase = ''
        mkdir -p $out/bin
        mv getrawentropy $out/bin
    '';
}