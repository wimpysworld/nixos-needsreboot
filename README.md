# nixos-needsreboot

Checks if you should reboot your NixOS machine in case an upgrade brought in
some new goodies. :)

# Usage as a flake

Add nixos-needsreboot to your `flake.nix`:

```nix
{
  inputs.nixos-needsreboot.url = "git+https://codeberg.org/Mynacol/nixos-needsreboot";

  outputs = { self, nixos-needsreboot }: {
    # Use in your outputs
  };
}
```
