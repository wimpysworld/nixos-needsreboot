{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
          version = "0.2.9";
          src = builtins.path { path = ./.; name = "source"; };
          cargoHash = "sha256-veQ2pRTXH4UM+oMQoh0oiZFvisyq8e8n+1oWTaXVwOI=";

          meta = with nixpkgs.lib; {
            license = licenses.gpl2Only;
            mainProgram = "nixos-needsreboot";
          };
        };
      });
    };
}
