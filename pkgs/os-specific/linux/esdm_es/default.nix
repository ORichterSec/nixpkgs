{ lib, stdenv, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation rec {
  pname = "esdm_es";
  version = "unstable-2023-06-19-${kernel.version}";

  src = fetchFromGitHub {
    owner = "smuellerdd";
    repo = "esdm";
    rev = "c7b717bbf353be84afefafba3f5a9312f9a619b0";
    hash = "sha256-JjNmiXpIIpnQhvGt2bwD601Zn8pcoYe4aYT1WwG0Cb8=";
  };

  sourceRoot = "source/addon/linux_esdm_es";

  hardeningDisable = [ "format" "pic" ];

  preBuild = ''
    substituteInPlace Makefile --replace "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    sed -i '/depmod/d' Makefile
  '';

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  outputs = [ "out" ];

  makeFlags = kernel.makeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with lib; {
    description = "A kernel module for esdm entropy gathering";
    homepage = "http://www.chronox.de/esdm.html";
    license = [ licenses.gpl2Only licenses.bsd2 ];
    maintainers = with maintainers; [ orichter thillux ];
    platforms = platforms.linux;
    outputsToInstall = [ "out" ];
  };
}
