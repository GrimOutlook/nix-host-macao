# Run the command
# `$ sudo nix run 'github:nix-community/disko/latest#disko-install' -- --flake '/tmp/config/etc/nixos#mymachine' --disk main /dev/disk/by-id/DRIVE_ID`
# This will override the `device` field with the path provided
{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S466NX0M753670D";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # NOTE: this describes the layout a *fresh* install should produce.
          # The live disk differs: the 500M ESP was too small to hold even two
          # generations (each costs ~215M, see `configurationLimit` in
          # hardware.nix), so on 2026-08-01 it was grown to 5G in place by
          # shrinking btrfs from the end and adding the new ESP after it. The
          # original ESP was then deleted, leaving 500M stranded as unallocated
          # space at the start of the disk and the partition order as
          # p2 (btrfs), p3 (ESP). Mounts are by partlabel, so that ordering
          # difference is immaterial at runtime; a reinstall restores this file.
          esp = {
            priority = 1;
            name = "ESP";
            size = "5G";
            type = "EF00";
            label = "NIXBOOT";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            label = "NIXROOT";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                # Subvolume name is different from mountpoint
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "relatime"
                  ];
                };
                # Subvolume name is the same as the mountpoint
                "/home" = {
                  mountOptions = [
                    "compress=zstd"
                    "relatime"
                  ];
                  mountpoint = "/home";
                };
                # Parent is not mounted so the mountpoint must be set
                "/nix" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/nix";
                };
                # Subvolume for the swapfile
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "24G";
                };
              };
            };
          };
        };
      };
    };
  };
}
