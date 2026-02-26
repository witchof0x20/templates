# Trimming for microVMs: disable unnecessary services and reduce closure size
{ lib, ... }: {
  # Perlless features (without pulling in the full profile)
  services.userborn.enable = true;
  system.tools.nixos-generate-config.enable = false;
  system.etc.overlay.enable = true;
  # No containers in VMs
  boot.enableContainers = false;
  # Disable fuse
  boot.blacklistedKernelModules = [ "fuse" ];
  systemd.mounts = [{ where = "/sys/fs/fuse/connections"; enable = false; }];
  # Inherit time from host
  services.timesyncd.enable = false;
  # Disable nscd
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];
  # No need for nix, build outside of the VM
  nix = {
    enable = false;
    channel.enable = false;
  };
  # Closure optimization
  programs.less.lessopen = null;
  security.sudo.enable = false;
  # Unnecessary services for a microvm
  systemd.oomd.enable = false;
  systemd.coredump.enable = false;
  services.fstrim.enable = false;
  systemd.services.lastlog2-import.enable = false;
  systemd.sockets.systemd-rfkill.enable = false;
  systemd.services.systemd-rfkill.enable = false;
  systemd.sockets.systemd-bootctl.enable = false;
}
