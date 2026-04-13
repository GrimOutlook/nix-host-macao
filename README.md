# Macao

Living Room PC/unofficial "Steam Machine"

## Current Issues

- Steam Big Picture navigation is laggy (no lag in-game)
- Launching games and opening the steam overlay results in flickering and
  artifacting.

## Notes

### Audio is low

Can be raised in the Steam settings

## Installation

1. Create a USB installer for your system using the ISO [here](https://nixos.org/download/). 

> [!NOTE]
> Make sure you get the NixOS ISO and not a Nix Package Manager installer.

2. Boot into the USB installer on your target system.
3. Optional: If you are on WiFi login using `nmtui`.
4. Run the below command to format your disk

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
nix run github:nix-community/disko/latest#disko -- \
  --flake github:GrimOutlook/nix-host-macao#macao \
  --disk main [/dev/disk/by-id/ID_TO_DISK]
```

5. Run the below command to install NixOS

```bash
nixos-install --flake github:GrimOutlook/nix-host-macao#macao --root /mnt
reboot
```

6. You should reboot into Steam.

> [!NOTE]
> The first boot into Steam will take longer as Steam will update itself and
> do some other internal operations that need to be taken care of on first
> boot.
