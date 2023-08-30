{ lib
, stdenv
, callPackage
, gnat
# , gprbuild
, gnat12
, gnatboot
, buildPackages
, pkgsCross
, glibc
, which
, autoconf
, binutils
, gcc
, gcc12
, autoPatchelfHook
, tree
}:
# let
#   gnatCross = callPackage ./boot.nix { };
# in
stdenv.mkDerivation rec {
    name = "helloAda";
    src = ./.;

    depsBuildBuild = [
      buildPackages.stdenv.cc
      # gprbuild
      # gnat
      gnatboot
      gnat
      # autoPatchelfHook
      binutils
      autoconf
      which
      # tree
    ];

    depsBuildHost = [
      pkgsCross.aarch64-multiplatform.pkgsBuildHost.gnat12
      # gnat
      pkgsCross.aarch64-multiplatform.pkgsBuildHost.gnatboot12
      pkgsCross.aarch64-multiplatform.pkgsBuildHost.binutils
      autoconf
    ];

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      
      cp ${./helloada.adb} helloada.adb
      
      TEST=${pkgsCross.aarch64-multiplatform.pkgsBuildHost.gnat12}
      # TEST=${pkgsCross.aarch64-multiplatform.pkgsBuildBuild.gnat12}
      # TEST=${pkgsCross.aarch64-multiplatform.pkgsBuildHost.gnat.targetPrefix}
      echo test
      echo $TEST
      echo 123
      #echo $(tree $TEST | grep gnatmake)
      echo $(which gnatmake)
      gnatmake helloada.adb
      #echo "${stdenv.buildPlatform.system},${stdenv.hostPlatform.system},${stdenv.targetPlatform.system} "

      runHook postBuild
    '';



    strictDeps = true;

    makeFlags = [ 
      # "PREFIX=$(out)"
      "CC=${stdenv.cc.targetPrefix}cc"
      "DESTDIR=${placeholder "out"}"
      # "PROCESSORS=$(NIX_BUILD_CORES)"
      # "TARGET=${stdenv.hostPlatform.config}"
      "HOST=${stdenv.buildPlatform.config}"
      "prefix=${placeholder "out"}"
      ] ++ lib.optionals (!stdenv.hostPlatform.isStatic) [
      "LIBRARY_TYPE=relocatable"
    ];

    dontFixup = true;
    dontStrip = true;
    dontStripHost = true;
    dontStripTarget = true;

    # dontConfigure = false;

    # configurePlatforms = [ "build" "host" "target" ];
    configurePlatforms = [ "${stdenv.buildPlatform.config}" "${stdenv.buildPlatform.config}" "${stdenv.targetPlatform.config}" ];

    installPhase = ''
        runHook preInstall
        echo "${stdenv.buildPlatform.system},${stdenv.hostPlatform.system},${stdenv.targetPlatform.system} "
        echo "${stdenv.buildPlatform.config},${stdenv.hostPlatform.config},${stdenv.targetPlatform.config} "
        mkdir -p $out/bin
        cp helloada $out/bin/
        runHook postInstall
    '';
}



    # gccA = gcc12.overrideAttrs { langAda = true; } ;

    # depsBuildTarget = [
    #   # gcc
    #   # gnatboot
    # ];

    # depsHostTarget = [
    #   pkgsCross.aarch64-multiplatform.gnat
    #   gnat
    # ];

    # configurePhase = ''
    #   runHook preConfig
    #   echo $(ls ${buildPackages.gnat.cc}/aarch64-unknown-linux-gnu/)
    #   echo $(find -name "configure" ${buildPackages.gnat.cc}/)
    #   runHook postConfig
    # '';

#      ${buildPackages.gnat-bootstrap}/gcc -c helloada.adb
    # buildPhase = ''
    #   runHook preBuild
    #   echo $(pwd)
    #   echo test
    #   echo "${stdenv.buildPlatform.system}"
    #   echo "${stdenv.hostPlatform.system}"
    #   echo "${stdenv.targetPlatform.system}"
    #   echo $(ls ${buildPackages.gnat}/bin/)
    #   OTHER=$(ls ${buildPackages.gnat}/bin/aarch64-unknown-linux-gnu-gnatmake)
      
    #   # echo $(which gnatmake)
    #   $OTHER helloada.adb
    #   # echo test2
    #   echo $(which aarch64-unknown-linux-gnu-gnatmake)
    #   # GNATMAKE=$(which gnatmake)
    #   # $GNATMAKE helloada.adb
    #   #${buildPackages.gnat-bootstrap}/bin/aarch64-unknown-linux-gnu-gnatmake -c helloada.adb
    #   echo test1
    #   #aarch64-unknown-linux-gnu-cc -o helloC -c helloada.adb
    #   runHook postBuild

    # buildPhase = ''
    #   runHook preBuild
    #   echo $(ls ${buildPackages.gnat.cc}/bin/)
    #   echo $(pwd)
    #   echo $(ls ${buildPackages.gnat.cc}/bin/)
    #   #${buildPackages.gnat.cc}/bin/${stdenv.cc.targetPrefix}gcc --help
    #   #${buildPackages.gnat.cc}/bin/${stdenv.cc.targetPrefix}gcc -c helloada.adb
    #   # ${buildPackages.gnat.cc}/bin/${stdenv.cc.targetPrefix}gnatbind helloada
    #   echo $(ls .)
    #   echo $(which gnat)
    #   #gcc -c helloada.adb
    #   echo $(which gnatmake)
    #   echo $($(which gnatmake) helloada.adb)
    #   echo test134
    #   gnat make helloada.adb
    #   echo test321
    #   # ${stdenv.cc.targetPrefix}gnatmake helloada.adb
    #   #${stdenv.cc.targetPrefix}gnatbind helloada.ali
    #   #${stdenv.cc.targetPrefix}gnatlink helloada.ali
    #   echo $(ls .)
    #   runHook postBuild
    #   ${stdenv.cc.targetPrefix}gnatmake helloada.adb
    # '';
    # '';