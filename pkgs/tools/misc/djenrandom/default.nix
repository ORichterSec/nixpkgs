{ lib
, stdenv
, fetchFromGitHub
,djent
}:

stdenv.mkDerivation rec {
  pname = "djenrandom";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "dj-on-github";
    repo = "djenrandom";
    rev = "${version}";
    sha256 = "sha256-r5UT8z8vvFZDffsl6CqBXuvBaZ/sl1WLxJi26CxkpAw=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin
    cp djenrandom $out/bin
  '';

  meta = {
    homepage = "http://www.deadhat.com/";
    description = "A C program to generate random data using several random models, with parameterized non uniformities and flexible output formats";
    license = with lib.licenses; [ gpl2Only ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ orichter thillux ];
  };
}
