# nixos-needsreboot

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/wimpysworld/nixos-needsreboot/badge)](https://flakehub.com/flake/wimpysworld/nixos-needsreboot)

Checks if you should reboot your NixOS ️❄️ machine in case an upgrade delivered new toys 🎁

This project is forked from <https://codeberg.org/Mynacol/nixos-needsreboot>, which was forked from <https://github.com/thefossguy/nixos-needsreboot>.
My version only makes aesthetic changes to the output ✨ to suit my taste.

## Usage as a flake

Add `nixos-needsreboot` to your `flake.nix`:

```nix
{
  inputs.nixos-needsreboot.url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/*.tar.gz";

  outputs = { self, nixos-needsreboot }: {
    # Use in your outputs
  };
}
```

## Usage

> Check if the currently active system needs a reboot
```shell
nixos-needsreboot
```

> Check a different system if it would require a reboot
```shell
nixos-needsreboot [/path/to/different-system]
```

## Test during NixOS system activation
```nix
  system.activationScripts = {
    nixos-needsreboot = {
      supportsDryActivation = true;
      text = "${lib.getExe nixos-needsreboot.packages.${pkgs.system}.default} \"$systemConfig\" || true";
    };
  };
```
