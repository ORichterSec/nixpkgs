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

stdenv.mkDerivation rec {
    pname = "esdm-client";
    version = "0.0.1";

    src = fetchFromGitHub {
        owner = "thillux";
        repo = "esdm-client";
        rev = "456d6d44f9fb251d45d053f3b1bcc71bd4b416c1";
        sha256 = "sha256-dqcSxa4VaWG+aNEWdtRR9CDuLC1StYd+/Zg/yPawpa4=";
    };

    patches = [
        ./code.patch
    ];

    nativeBuildInputs = [ meson ninja pkg-config esdm boost jsoncpp protobufc];
    buildInputs = [ esdm jsoncpp catch2 protobufc];

    mesonBuildType = "release";

     # https://github.com/NixOS/nixpkgs/issues/86131
    BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
    BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";
}