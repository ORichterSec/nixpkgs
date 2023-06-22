{ lib
, stdenv
, fetchFromGitHub
, protobufc
, pkg-config
, fuse3
, meson
, ninja
, libselinux
, jitterentropy
  # A more detailed explaination of the following meson build options can be found
  # in the source code of esdm.
  # A brief explanation is given:
, selinux ? false # meson build option for selinux support
, drng_hash_drbg ? true  # meson build option for setting the default drng callback
, drng_chacha20 ? false # meson build option for setting the default drng callback
, ais2031 ? true # meson build option for setting the seeding strategy to be compliant with AIS 20/31
, linux-devfiles ? true # meson build option to enable linux /dev/random and /dev/urandom support
, linux-getrandom ? true # meson build option to enable linux getrandom support
, es_jitterRng ? true # meson build option to enable support for the entropy source: jitter rng
, es_cpu ? true # meson build option to enable support for the entropy source: cpu-based entropy
, es_kernel ? true # meson build option to enable support for the entropy source: kernel-based entropy
, es_irq ? true # meson build option to enable support for the entropy source: interrupt-based entropy
, es_sched ? true # meson build option to enable support for the entropy source: scheduler-based entropy
, es_hwrand ? true # meson build option to enable support for the entropy source: /dev/hwrng
, hash_sha512 ? false # meson build option for the conditioning hash: SHA2-512
, hash_sha3_512 ? true # meson build option for the conditioning hash: SHA3-512
}:

assert drng_hash_drbg != drng_chacha20;
assert hash_sha512 != hash_sha3_512;

stdenv.mkDerivation rec {
  pname = "esdm";
  version = "unstable-2023-06-19";

  src = fetchFromGitHub {
    owner = "smuellerDD";
    repo = "esdm";
    rev = "c7b717bbf353be84afefafba3f5a9312f9a619b0";
    sha256 = "sha256-JjNmiXpIIpnQhvGt2bwD601Zn8pcoYe4aYT1WwG0Cb8=";
  };

  nativeBuildInputs = [ meson pkg-config ninja ];
  buildInputs = [ protobufc fuse3 jitterentropy ]
    ++ lib.optional selinux libselinux;

  mesonFlags = [
    (lib.mesonBool "b_lto" false)
    (lib.mesonBool "ais2031" ais2031)
    (lib.mesonEnable "linux-devfiles" linux-devfiles)
    (lib.mesonEnable "linux-getrandom" linux-getrandom)
    (lib.mesonEnable "es_jent" es_jitterRng)
    (lib.mesonEnable "es_cpu" es_cpu)
    (lib.mesonEnable "es_kernel" es_kernel)
    (lib.mesonEnable "es_irq" es_irq)
    (lib.mesonEnable "es_sched" es_sched)
    (lib.mesonEnable "es_hwrand" es_hwrand)
    (lib.mesonEnable "hash_sha512" hash_sha512)
    (lib.mesonEnable "hash_sha3_512" hash_sha3_512)
    (lib.mesonEnable "selinux" selinux)
    (lib.mesonEnable "drng_hash_drbg" drng_hash_drbg)
    (lib.mesonEnable "drng_chacha20" drng_chacha20)
  ];

  doCheck = true;

  strictDeps = true;
  mesonBuildType = "release";

  postInstall = ''
    mkdir -p $out/share/linux_esdm_es
    cp -r ../addon/linux_esdm_es/*.patch $out/share/linux_esdm_es/
  '';

  meta = {
    homepage = "https://www.chronox.de/esdm.html";
    description = "Entropy Source and DRNG Manager in user space";
    license = with lib.licenses; [ gpl2Only bsd3 ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ orichter thillux ];
  };
}
