{ stdenv, fetchFromGitHub, pkg-config, python3, which, gettext, openssl, cmake, zlib, uriparser, avahi, bash, ffmpeg-headless, libhdhomerun }:

stdenv.mkDerivation rec {
  pname = "tvheadend";
  version = "4.2.8";

  src = fetchFromGitHub {
    owner = "tvheadend";
    repo = "tvheadend";
    rev = "v${version}";
    sha256 = "sha256-lQz+sqLmevHdaQ8WCLowqXEnAeJwctAsUIreJXIqAPc=";
  };

  nativeBuildInputs = [ pkg-config python3 which gettext cmake bash ];
  buildInputs = [ openssl zlib uriparser avahi ffmpeg-headless libhdhomerun ];

  # Prevent cmake from taking over the build
  dontUseCmakeConfigure = true;

  # Patch scripts to use Nix bash instead of /usr/bin/env
  postPatch = ''
    patchShebangs support/
  '';

  # Use older C standard and allow legacy code patterns
  # -fcommon: Allow multiple definitions of globals (pre-GCC10 behavior)
  # -Wno-use-after-free: Ignore legacy code issues
  env.NIX_CFLAGS_COMPILE = "-std=gnu11 -fcommon -Wno-use-after-free";

  # Disable network fetching during build and use system ffmpeg
  configureFlags = [
    "--disable-dvbscan"
    "--disable-ffmpeg_static"
    "--disable-hdhomerun_static"
    "--disable-libav"
  ];
}
