# nixos-needsreboot

Checks if you should reboot your NixOS machine in case an upgrade brought in
some new goodies. :)

# Usage as a flake

Add nixos-needsreboot to your `flake.nix`:

```nix
{
  inputs.nixos-needsreboot.url = "https://codeberg.org/Mynacol/nixos-needsreboot/archive/main.tar.gz";

  outputs = { self, nixos-needsreboot }: {
    # Use in your outputs
  };
}
```

# Program Usage

> Check if the currently active system needs a reboot
```
nixos-needsreboot
```

> Check a different system if it would require a reboot
```
nixos-needsreboot [/path/to/different-system]
```

# Test whether to reboot during NixOS system activation
```nix
  system.activationScripts = {
    nixos-needsreboot = {
      supportsDryActivation = true;
      text = "${lib.getExe nixos-needsreboot.packages.${pkgs.system}.default} \"$systemConfig\" || true";
    };
  };
```
