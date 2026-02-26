# QEMU-specific overrides
{ lib, ... }: {
  microvm = {
    # Use qemu
    hypervisor = "qemu";
    # Use virtio-console (hvc0) instead of emulated 8250 UART (ttyS0)
    qemu = {
      serialConsole = false;
      extraArgs = [
        "-device"
        "virtio-serial-pci"
        "-device"
        "virtconsole,chardev=stdio"
      ];
    };
  };
  boot = {
    # Use fancy accelerated console
    kernelParams = [ "console=hvc0" "8250.nr_uarts=0" ];
    # Have that console in initrd
    initrd.kernelModules = [ "virtio_console" ];
  };
  # No VGA display, only serial console
  systemd.services."autovt@tty1".enable = false;
  services.logind.settings.Login.NAutoVTs = 0;
  # Override headless.nix disabling our interactive console
  systemd.services."serial-getty@hvc0".enable = lib.mkForce true;
}
