{ stdenv, fetchzip, libusb1, cmake, pkg-config, usbutils, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "oscam";
  version = "11943";

  src = fetchzip {
    url = "https://git.streamboard.tv/common/oscam/-/archive/${version}/oscam-${version}.tar.gz?ref_type=tags";
    sha256 = "sha256-gTitrFnuLAKDWEEJltTEn8S4giFm0UTaeLrm4QPigPk=";
  };

  nativeBuildInputs = [ cmake pkg-config makeWrapper ];
  buildInputs = [ libusb1 usbutils ];

  cmakeFlags = [
    "-DUSE_LIBUSB=1"
  ];

  postFixup = ''
    wrapProgram $out/bin/oscam \
      --prefix PATH : ${usbutils}/bin
  '';
}
