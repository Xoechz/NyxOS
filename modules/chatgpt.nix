{ inputs, ... }: {
  perSystem = { system, lib, ... }:
    let
      chatgptPkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: lib.getName pkg == "chatgpt";
      };
    in
    {
      packages = lib.optionalAttrs (system == "x86_64-linux") {
        chatgpt = chatgptPkgs.callPackage ../packages/chatgpt { };
      };
    };

  # System Module chatgpt: install the official ChatGPT desktop application with Codex
  flake.modules.nixos.chatgpt = { pkgs, lib, system, ... }: {
    environment.systemPackages = lib.mkIf (system == "x86_64-linux") [
      (pkgs.callPackage ../packages/chatgpt { })
    ];
  };
}
