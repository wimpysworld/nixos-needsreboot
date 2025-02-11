{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # helpers for producing system-specific outputs
      supportedSystems = [
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            rustup
            gdb
            pkg-config
            # formatting this flake
            nixpkgs-fmt
          ];
        };
      });

      packages = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.rustPlatform.buildRustPackage {
          pname = "nixos-needsreboot";
          version = "0.2.5";
          src = ./.;
          cargoHash = "sha256-QG2eAEP1eX6UL1U/XsNo/yvYLJHaq+wsT5AR9lh+BtQ=";
          #cargoHash = nixpkgs.lib.fakeHash;

          meta = with nixpkgs.lib; {
            license = licenses.gpl2Only;
            mainProgram = "nixos-needsreboot";
          };
        };
      });
    };
}
