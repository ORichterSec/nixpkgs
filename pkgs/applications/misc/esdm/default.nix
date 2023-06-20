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
, drng_hash_drbg ? true
, drng_chacha20 ? false
, ais2031Support ? true
, linux-devfiles ? true
, linux-getrandom ? true
, es_jitterRng ? true
, es_cpu ? true
, es_kernel ? true
, es_irq ? true
, es_sched ? true
, es_hwrand ? true
, hash_sha512 ? false
, hash_sha3_512 ? true
, debugMode ? true
, node ? false
, maxrandombits ? "11"
}:

assert drng_hash_drbg -> !drng_chacha20;
assert !drng_hash_drbg -> drng_chacha20;
assert hash_sha512 -> !hash_sha3_512;
assert !hash_sha512 -> hash_sha3_512;

stdenv.mkDerivation rec {
  pname = "esdm";
  version = "unstable-2023-06-19";

  src = fetchFromGitHub {
    owner = "smuellerDD";
    repo = "esdm";
    rev = "c7b717bbf353be84afefafba3f5a9312f9a619b0";
    sha256 = "sha256-JjNmiXpIIpnQhvGt2bwD601Zn8pcoYe4aYT1WwG0Cb8=";
  };

  patches = [
    ./test.patch
  ]
  #add debug option in the ExecStart
  ++ lib.lists.optional debugMode ./debugMode.patch
  ;

  nativeBuildInputs = [ meson pkgconfig ninja ];
  buildInputs = [ protobufc fuse3 jitterentropy ]
    ++ lib.lists.optional selinuxSupport libselinux;

  mesonFlags = [
    (lib.strings.mesonBool "b_lto" false)
    (lib.strings.mesonBool "ais2031" ais2031Support)
    (lib.strings.mesonEnable "linux-devfiles" linux-devfiles)
    (lib.strings.mesonEnable "linux-getrandom" linux-getrandom)
    (lib.strings.mesonEnable "es_jent" es_jitterRng)
    (lib.strings.mesonEnable "es_cpu" es_cpu)
    (lib.strings.mesonEnable "es_kernel" es_kernel)
    (lib.strings.mesonEnable "es_irq" es_irq)
    (lib.strings.mesonEnable "es_sched" es_sched)
    (lib.strings.mesonEnable "es_hwrand" es_hwrand)
    (lib.strings.mesonEnable "hash_sha512" hash_sha512)
    (lib.strings.mesonEnable "hash_sha3_512" hash_sha3_512)
    (lib.strings.mesonEnable "selinux" selinuxSupport)
    (lib.strings.mesonEnable "drng_hash_drbg" drng_hash_drbg)
    (lib.strings.mesonEnable "drng_chacha20" drng_chacha20)
    (lib.strings.mesonEnable "node" node)
    (lib.strings.mesonOption "maxrandombits" maxrandombits)
  ];

  mesonBuildType = "debug";

  preBuild = ''
    mkdir -p $out/addon/linux_esdm_es
    cp -r ../addon/linux_esdm_es/*.patch $out/addon/linux_esdm_es/
  '';

  meta = {
    homepage = "https://www.chronox.de/esdm.html";
    description = "Entropy Source and DRNG Manager in user space";
    license = [ lib.licenses.gpl2Only lib.licenses.bsd3 ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ orichter thillux ];
  };
}
