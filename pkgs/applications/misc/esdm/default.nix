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
, libselinux
, jitterentropy
, selinuxSupport ? false
, drng_chacha20 ? true
, ais2031Support ? true
, linux-devfiles ? true
, linux-getrandom ? true
, es_jitterRng ? true
, es_cpu ? true
, es_kernel ? true
, es_irq ? true
, es_sched ? true
, es_hwrand ? true
, hash_sha512 ? true
, hash_sha3_512 ? false
, debugMode ? false
}:

stdenv.mkDerivation rec {
  pname = "esdm";
  version = "unstable-2023-06-12";

  src = fetchFromGitHub {
    owner = "smuellerDD";
    repo = "esdm";
    rev = "c7b717bbf353be84afefafba3f5a9312f9a619b0";
    sha256 = "sha256-JjNmiXpIIpnQhvGt2bwD601Zn8pcoYe4aYT1WwG0Cb8=";
  };

  patches = []
  #add debug option in the ExecStart
  ++ lib.lists.optional debugMode ./debugMode.patch
  ;

  nativeBuildInputs = [ meson pkgconfig ninja ];
  buildInputs = [ protobufc fuse3 jitterentropy libselinux ];

  mesonFlags = [
    "-Db_lto=false"
  ] ++ lib.lists.optional (!selinuxSupport) "-Dselinux=disabled"
  ++ lib.lists.optionals drng_chacha20 [
    "-Ddrng_hash_drbg=disabled"
    "-Ddrng_chacha20=enabled"
  ]
  ++ lib.lists.optional ais2031Support "-Dais2031=true"
  ++ lib.lists.optional (!linux-devfiles) "-Dlinux-devfiles=disabled"
  ++ lib.lists.optional (!linux-getrandom) "-Dlinux-getrandom=disabled"
  ++ lib.lists.optional (!es_jitterRng) "-Des_jent=disabled"
  ++ lib.lists.optional (!es_cpu) "-Des_cpu=disabled"
  ++ lib.lists.optional (!es_kernel) "-Des_kernel=disabled"
  ++ lib.lists.optional (!es_irq) "-Des_irq=disabled"
  ++ lib.lists.optional (!es_sched) "-Des_sched=disabled"
  ++ lib.lists.optional (!es_hwrand) "-Des_hwrand=disabled"
  ++ lib.lists.optional (!hash_sha512) "-Dhash_sha512=disabled"
  ++ lib.lists.optional (!hash_sha3_512) "-Dhash_sha3_512=disabled"
  ;
  
  mesonBuildType = "release";

  meta = {
    homepage = "https://www.chronox.de/esdm.html";
    description = "Entropy Source and DRNG Manager in user space";
    license = [ lib.licenses.gpl2Only lib.licenses.bsd3 ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ orichtersec thillux ];
  };
}
