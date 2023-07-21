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
        rev = "fe4b4d1f8dd56081d3da9592e4ca7616562b7164";
        sha256 = "sha256-1bShilXJcOQj2Xg4SynObaYGyZ7l/v+oSpdIrszSf6U=";
    };

    # patches = [
    #     ./code.patch
    # ];

    nativeBuildInputs = [ meson ninja pkg-config esdm boost jsoncpp protobufc];
    buildInputs = [ esdm jsoncpp catch2 protobufc];

    mesonBuildType = "release";

     # https://github.com/NixOS/nixpkgs/issues/86131
    BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
    BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";
}