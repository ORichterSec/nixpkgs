{ lib
, stdenv
, fetchFromGitHub
, cmake
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

    nativeBuildInputs = [ pkg-config ];

    # buildPhase = "make -f ./Makefile all";
    #buildPhase = "gcc -Wall -pedantic -Wextra -o getrawentropy ./test/getrawentropy.c";
    preConfig = "echo ''";
    buildPhase = "${stdenv.cc.targetPrefix}gcc -o getrawentropy ./test/getrawentropy.c";
    installPhase = ''
        mkdir -p $out/bin
        mv getrawentropy $out/bin
    '';
}