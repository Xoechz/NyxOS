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

  # Pre-fetch DVB scan tables to avoid network access during build
  dtv-scan-tables = fetchFromGitHub {
    owner = "tvheadend";
    repo = "dtv-scan-tables";
    rev = "cbcd7389a66e86bab8c3f73e7a513196fdf8bd60";
    sha256 = "sha256-JUnjximbLMEN2T7+wOBw63ZtdO6HgpeANqyyoUI7P7U=";
  };

  nativeBuildInputs = [ pkg-config python3 which gettext cmake bash ];
  buildInputs = [ openssl zlib uriparser avahi ffmpeg-headless libhdhomerun ];

  # Prevent cmake from taking over the build
  dontUseCmakeConfigure = true;

  # Patch scripts to use Nix bash instead of /usr/bin/env
  postPatch = ''
    patchShebangs support/
    
    # Copy pre-fetched DVB scan tables to avoid network fetch during build
    mkdir -p data/dvb-scan
    cp -r ${dtv-scan-tables}/* data/dvb-scan/
    chmod -R +w data/dvb-scan
  '';

  # Use older C standard and allow legacy code patterns
  # -fcommon: Allow multiple definitions of globals (pre-GCC10 behavior)
  # -Wno-use-after-free: Ignore legacy code issues
  env.NIX_CFLAGS_COMPILE = "-std=gnu11 -fcommon -Wno-use-after-free";

  # Disable network fetching during build and use system ffmpeg
  configureFlags = [
    "--disable-ffmpeg_static"
    "--disable-hdhomerun_static"
    "--disable-libav"
  ];

  # Restore DVB scan tables before install phase (build cleans them up)
  preInstall = ''
    mkdir -p data/dvb-scan
    cp -r ${dtv-scan-tables}/* data/dvb-scan/
  '';
}
