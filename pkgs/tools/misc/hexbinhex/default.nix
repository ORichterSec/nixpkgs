{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hexbinhex";
  version = "unstable-2023-03-31";

  src = fetchFromGitHub {
    owner = "dj-on-github";
    repo = "hexbinhex";
    rev = "41802864f4d281a852a5dc83d377a83013264485";
    sha256 = "sha256-ODHaVG0mEQ7yY0iNJOudU08ElxqEiyr4oHAHRrlpd28=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin2hex $out/bin
    cp ./bin201 $out/bin
    cp ./012bin $out/bin
    cp ./hex2bin $out/bin
    cp ./bin2nistoddball $out/bin
    cp ./nistoddball2bin $out/bin
  '';

  meta = {
    homepage = "https://github.com/dj-on-github/hexbinhex";
    description = "Six utility programs to convert between hex, binary, ascii-binary and the oddball NIST format for 90B testing.";
    license = with lib.licenses; [ gpl2Only ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ orichter thillux ];
  };
}
