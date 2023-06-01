{ lib, stdenv, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation rec {
  pname = "esdm_es";
  version = "unstable-2023-06-12-${kernel.version}";

  src = fetchFromGitHub {
    owner = "smuellerdd";
    repo = "esdm";
    rev = "09845ddddd71a5650e1e1889c19a323f28714cfe";
    hash = "sha256-S/5g8lpAb/0TSTa39TkVQuWOVNzj/hyr/mz8HlNYXs0=";
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
    maintainers = with maintainers; [ orichtersec thillux ];
    platforms = platforms.linux;
    outputsToInstall = [ "out" ];
  };
}
