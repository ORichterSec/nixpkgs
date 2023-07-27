{ lib
, stdenv
, fetchFromGitHub
, mpfr
}:

stdenv.mkDerivation rec {
  pname = "djent";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "dj-on-github";
    repo = "djent";
    rev = "${version}";
    sha256 = "sha256-inMh7l/6LlrVnIin+L+fj+4Lchk0Xvt09ngVrCuvphE=";
  };

  buildInputs = [ mpfr ];

  installPhase = ''
    mkdir -p $out/bin
    cp djent $out/bin
  '';

  meta = {
    homepage = "http://www.deadhat.com/";
    description = "A reimplementation of the Fourmilab/John Walker random number test program ent with several improvements";
    license = with lib.licenses; [ gpl2Only ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ orichter thillux ];
  };
}
