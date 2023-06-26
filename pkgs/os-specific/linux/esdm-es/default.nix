{ lib, stdenv, fetchFromGitHub, kernel, kmod, esdm }:

stdenv.mkDerivation rec {
  pname = "esdm-es";
  version = "0.6.0";

  src = esdm.src;

  sourceRoot = "source/addon/linux_esdm_es";

  hardeningDisable = [ "format" "pic" ];

  preBuild = ''
    substituteInPlace Makefile --replace "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    sed -i '/depmod/d' Makefile
  '';

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

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
