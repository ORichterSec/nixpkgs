{ lib
, stdenv
, gcc
, pkgsCross
, buildPackages
}:
stdenv.mkDerivation {
    name = "helloC";
    src = ./.;

    depsBuildHost = [
      gcc
    ];

    buildPhase = ''
        runHook preBuild
        echo $(pwd)
        echo test12435
        echo "${stdenv.buildPlatform.system}"
        echo "${stdenv.hostPlatform.system}"
        echo "${stdenv.targetPlatform.system}"
        ${stdenv.cc.targetPrefix}gcc -o helloC hello.c
        runHook postBuild
    '';


    makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

    # makeFlags = [
    #   "PREFIX=$(out)"
    #   "DESTDIR=${placeholder "out"}"
    #   "TARGET=${stdenv.targetPlatform.config}"
    # ];

    dontConfigure = false;

    installPhase = ''
        runHook preInstall
        echo "${stdenv.hostPlatform.system},${stdenv.targetPlatform.system}"
        mkdir -p $out/bin
        cp helloC $out/bin/
        runHook postInstall
    '';
}