{ ... }:
{
  # Home Module shell-scripts: provide Nix-built commands for rebuild, deployment, cleanup, system pinning, and common shell workflows
  flake.modules.homeManager.shell-scripts = { config, pkgs, ... }:
    let
      makeCommand = name: text: runtimeInputs: pkgs.writeShellApplication {
        inherit name runtimeInputs text;
      };

      rebuild = makeCommand "rebuild" ''
        sudo echo Rebuilding...
        nh os switch "$@"
      '' [ pkgs.nh ];

      update = makeCommand "update" ''
        sudo echo Updating...
        nh os switch -u "$@"
      '' [ pkgs.nh ];

      pmReset = makeCommand "pm-reset" ''
        rm "${config.home.homeDirectory}/.local/share/plasma-manager/last_run_"*
        "${config.home.homeDirectory}/.local/share/plasma-manager/run_all.sh"
      '' [ pkgs.coreutils ];

      buildPinnedNixPi = makeCommand "build-pinned-nixPi" ''
        flake="${config.home.homeDirectory}/NyxOS"
        nixpi=$(nix build --no-link --print-out-paths "$flake#nixosConfigurations.NixPi.config.system.build.toplevel")

        sudo ln -sfn "$nixpi" /nix/var/nix/gcroots/NixPi-latest
      '' [ pkgs.coreutils pkgs.nix ];

      buildPinnedPiKistn = makeCommand "build-pinned-piKistn" ''
        flake="${config.home.homeDirectory}/NyxOS"
        pikistn=$(nix build --no-link --print-out-paths "$flake#nixosConfigurations.PiKistn.config.system.build.toplevel")

        sudo ln -sfn "$pikistn" /nix/var/nix/gcroots/PiKistn-latest
      '' [ pkgs.coreutils pkgs.nix ];

      deployToNixPi = makeCommand "deploy-to-nixPi" ''rebuild --target-host NixPi -H NixPi "$@"'' [ rebuild ];
      deployToPiKistn = makeCommand "deploy-to-piKistn" ''rebuild --target-host PiKistn -H PiKistn "$@"'' [ rebuild ];
      deployToFredPC = makeCommand "deploy-to-fredPC" ''rebuild --target-host FredPC -H FredPC "$@"'' [ rebuild ];
      deployToEliasPC = makeCommand "deploy-to-eliasPC" ''rebuild --target-host EliasPC -H EliasPC "$@"'' [ rebuild ];
      deployToEliasLaptop = makeCommand "deploy-to-eliasLaptop" ''rebuild --target-host EliasLaptop -H EliasLaptop "$@"'' [ rebuild ];
    in
    {
      home.packages = [
        (makeCommand "ll" ''exec eza -la --git "$@"'' [ pkgs.eza ])
        (makeCommand "etree" ''exec eza -T --git -a -I '.git|node_modules|bin|obj' "$@"'' [ pkgs.eza ])
        rebuild
        update
        (makeCommand "update-lock" ''
          echo Updating Lock file...
          nix flake update "$@"
        '' [ pkgs.nix ])
        (makeCommand "regenerate" ''
          cd "${config.home.homeDirectory}/NyxOS"
          nix run .#write-flake "$@"
        '' [ pkgs.nix ])
        (makeCommand "cleanup-nix" ''
          sudo nix store optimise
          nh clean all "$@"
        '' [ pkgs.nh pkgs.nix ])
        pmReset
        (makeCommand "pm-rebuild" ''
          rebuild
          pm-reset
        '' [ rebuild pmReset ])
        (makeCommand "show-leftovers" ''
          nix-store --gc --print-roots | grep -E -v '^(/nix/var|/run/\w+-system|\{memory|/proc)' "$@"
        '' [ pkgs.gnugrep pkgs.nix ])
        (makeCommand "full-rebuild" ''
          cd "${config.home.homeDirectory}/NyxOS"
          git pull
          rebuild "$@"
        '' [ pkgs.git rebuild ])
        (makeCommand "full-update" ''
          cd "${config.home.homeDirectory}/NyxOS"
          git pull
          update "$@"
        '' [ pkgs.git update ])
        deployToNixPi
        deployToPiKistn
        deployToFredPC
        deployToEliasPC
        deployToEliasLaptop
        buildPinnedNixPi
        buildPinnedPiKistn
        (makeCommand "deploy-pinned-nixPi" ''deploy-to-nixPi "$@" && build-pinned-nixPi'' [ buildPinnedNixPi deployToNixPi ])
        (makeCommand "deploy-pinned-piKistn" ''deploy-to-piKistn "$@" && build-pinned-piKistn'' [ buildPinnedPiKistn deployToPiKistn ])
        (makeCommand "dev-certs-reload" ''
          certs="${config.home.homeDirectory}/NyxOS/resources/certs"
          mkdir -p "$certs"
          dotnet dev-certs https --format PEM -ep "$certs/$(hostname)-dev-cert.pem"
          rebuild "$@"
        '' [ rebuild ])
        (makeCommand "boot-eliaspc" ''wakeonlan -i 192.168.0.255 d8:43:ae:22:f1:be "$@"'' [ pkgs.wakeonlan ])
      ];
    };
}
