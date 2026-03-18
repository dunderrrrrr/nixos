{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  fontconfig,
  libgcc,
  libGL,
  mesa,
  vulkan-loader,
  wayland,
  libxkbcommon,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "gram-editor";
  version = "1.0.0";

  src = fetchurl {
    url = "https://codeberg.org/GramEditor/gram/releases/download/${version}/gram-linux-x86_64-${version}.tar.gz";
    hash = "sha256-ErlFc5OWMS2a8nsYZtWwWsbK94QVAneY9aaMEoK+wzE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    libgcc.lib
    libGL
    mesa
    vulkan-loader
    wayland
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  # The tarball unpacks to a `gram.app/` directory
  sourceRoot = "gram.app";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Go CLI wrapper
    install -Dm755 bin/gram             $out/bin/gram

    # Actual Rust editor binary — the CLI locates this via --gram
    install -Dm755 libexec/gram-editor  $out/libexec/gram-editor

    # Shared support files
    cp -r share $out/share

    # Desktop entry
    install -Dm644 share/applications/gram.desktop \
      $out/share/applications/se.ziran.Gram.desktop
    substituteInPlace $out/share/applications/se.ziran.Gram.desktop \
      --replace "Exec=gram" "Exec=$out/bin/gram"

    runHook postInstall
  '';

  # autoPatchelfHook patches both binaries automatically.
  # The CLI passes --gram so it can find the editor binary in the store.
  # Vulkan loader must be in LD_LIBRARY_PATH at runtime.
  postFixup = ''
    wrapProgram $out/bin/gram \
      --add-flags "--gram $out/libexec/gram-editor" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [vulkan-loader libGL wayland]}"

    wrapProgram $out/libexec/gram-editor \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [vulkan-loader libGL wayland]}"
  '';

  meta = {
    description = "A code editor for humanoid apes and grumpy toads — opinionated Zed fork, no AI/telemetry";
    homepage = "https://gram.liten.app/";
    license = lib.licenses.gpl3Only;
    maintainers = [];
    platforms = ["x86_64-linux"];
    mainProgram = "gram";
  };
}
