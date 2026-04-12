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
          esp = {
            priority = 1;
            name = "ESP";
            size = "500M";
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
