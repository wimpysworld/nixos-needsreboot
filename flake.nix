{
  description = "nixos-needsreboot";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-schemas = {
      url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake outputs that other flakes can use
  outputs = { self, nixpkgs, flake-schemas, rust-overlay, ... }:
    let
      cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
      cargoPackageVersion = cargoToml.package.version;
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      commitHash = self.shortRev or self.dirtyShortRev or "unknown";
      version = "${cargoPackageVersion}-${commitHash}";

      # Nixpkgs overlays
      overlays = [
        rust-overlay.overlays.default
        (final: prev: {
          rustToolchain = final.rust-bin.stable.latest.default;
        })
      ];

      # Helpers for producing system-specific outputs
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit overlays system; };
      });
    in
    {
      # Schemas tell Nix about the structure of the flake outputs
      schemas = flake-schemas.schemas;

      # Development environment
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          # Packages available in the environment
          packages = with pkgs; [
            cargo-watch
            cargo-edit
            clippy
            nixpkgs-fmt
            rustToolchain
            rust-analyzer
            rustfmt
          ];

          # Environment variables that help with development
          shellHook = ''
            echo "🦀 Rust development environment loaded"
            echo "📝 rust-analyzer tools available"
            export CARGO_BUILD_INCREMENTAL=false
            export RUST_BACKTRACE=full
          '';
        };
      });

      # Package outputs from the flake
      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.rustPlatform.buildRustPackage {
          pname = cargoToml.package.name;
          inherit version;
          src = builtins.path { path = ./.; name = "source"; };
          cargoLock.lockFile = ./Cargo.lock;
          meta = with nixpkgs.lib; {
            description = cargoToml.package.description;
            homepage = cargoToml.package.repository;
            license = licenses.gpl2Only;
            maintainers = [
              {
                github = "flexiondotorg";
              }
            ];
            mainProgram = "nixos-needsreboot";
          };
        };
      });
    };
}
