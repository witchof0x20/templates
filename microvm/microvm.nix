{ hostname ? "microvm" }:
{ lib, pkgs, config, ... }:
let
  hash = builtins.hashString "sha256" hostname;
  # Locally-administered unicast MAC (02:xx:xx:xx:xx:xx)
  mac = "02:${builtins.substring 0 2 hash}:${builtins.substring 2 2 hash}:${builtins.substring 4 2 hash}:${builtins.substring 6 2 hash}:${builtins.substring 8 2 hash}";
in
{
  microvm = {
    # Mount the host nix store
    shares = [{
      proto = "virtiofs";
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
    }];
    # Socket filename (TODO: look into whether i can shuffle this away)
    socket = "control.socket";
  };
  # Networking stuff
  networking = {
    hostName = hostname;
    useDHCP = false;
    useNetworkd = true;
    tempAddresses = "disabled";
    # Not needed with qemu user networking
    firewall.enable = false;
  };
  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "enp0s3";
      networkConfig.DHCP = "yes";
    };
  };
  microvm.interfaces = [{
    type = "user";
    id = "usernet";
    mac = mac;
  }];
  services.resolved.enable = true;
  # User networking so disable ssh for now
  # services.openssh.enable = true;
  # TODO: remove this when we start running real things on it
  services.getty.autologinUser = "root";
  # Poweroff when the console shell exits
  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/hvc0" ] && [ "$USER" = "root" ]; then
      trap "${config.systemd.package}/bin/poweroff" EXIT
    fi
  '';
  system.stateVersion = "25.11";
}
