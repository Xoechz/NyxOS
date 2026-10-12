{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, asar
, makeWrapper
, wrapGAppsHook3
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, gdk-pixbuf
, glib
, gtk3
, libGL
, libgbm
, libnotify
, libpulseaudio
, libsecret
, libusb1
, libx11
, libxcb
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxkbcommon
, libxrandr
, nspr
, nss
, openssl
, pango
, systemd
, tpm2-tss
, xdg-utils
}:

stdenv.mkDerivation rec {
  pname = "chatgpt";
  version = "26.1007.21434";

  # The versioned URL serves the same release as the official latest download.
  # SHA-256 is published in the upstream Debian repository's Packages index.
  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
    sha256 = "276b5341c3d74b261d3ad52106f7fa7edde06841e4767fe2a40cb54099b1f3ed";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    asar
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libGL
    libgbm
    libnotify
    libpulseaudio
    libsecret
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    openssl
    pango
    stdenv.cc.cc.lib
    systemd
    tpm2-tss
  ];

  # Electron loads these libraries dynamically rather than through DT_NEEDED.
  runtimeDependencies = map lib.getLib [
    libGL
    libnotify
    libpulseaudio
    libsecret
    systemd
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;
  dontWrapGApps = true;

  postPatch = ''
    asar extract usr/lib/chatgpt/resources/app.asar app

    # fs.cp preserves the store's read-only modes. The app subsequently edits
    # its copied plugins, so restore owner write access only on that local copy.
    substituteInPlace app/.vite/build/main-*.js \
      --replace-fail \
        'await x.default.cp(e,t,{recursive:!0,verbatimSymlinks:!0});return' \
        'await x.default.cp(e,t,{recursive:!0,verbatimSymlinks:!0});await(async function writable(p){let s=await x.default.lstat(p);if(s.isSymbolicLink())return;await x.default.chmod(p,s.mode|(s.isDirectory()?448:128));if(s.isDirectory())for(let n of await x.default.readdir(p))await writable((0,C.join)(p,n))})(t);return'

    # Native Node modules must remain accessible as real files for dlopen.
    asar pack app usr/lib/chatgpt/resources/app.asar --unpack-dir node_modules
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib" "$out/share"
    cp -a usr/lib/chatgpt "$out/lib/"
    cp -a usr/share/applications usr/share/metainfo usr/share/pixmaps "$out/share/"
    cp -a usr/share/doc "$out/share/"

    # Use Electron's GTK backend; the optional Qt shims require separate Qt ABIs.
    rm "$out/lib/chatgpt/libqt5_shim.so" "$out/lib/chatgpt/libqt6_shim.so"

    # The bundle also ships musl prebuilds, which cannot run on NixOS's glibc.
    find "$out/lib/chatgpt/resources" -type f \
      \( -path '*-musl/*' -o -name '*.musl.node' \) -delete

    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail 'Exec=chatgpt %U' "Exec=$out/bin/chatgpt %U"

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/lib/chatgpt/ChatGPT" "$out/bin/chatgpt" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  meta = {
    description = "Official ChatGPT desktop application with Codex";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "chatgpt";
  };
}
