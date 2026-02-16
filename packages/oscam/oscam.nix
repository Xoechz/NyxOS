{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "oscam";
  version = "11943";

  src = fetchzip {
    url = "https://git.streamboard.tv/common/oscam/-/archive/${version}/oscam-${version}.tar.gz?ref_type=tags";
    sha256 = "sha256-gTitrFnuLAKDWEEJltTEn8S4giFm0UTaeLrm4QPigPk=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp Distribution/oscam-2.26.02-11943@-x86_64-unknown-linux-gnu $out/bin/oscam
    chmod +x $out/bin/oscam
  '';
}
