{
  description = "Jade's MicroVM config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, microvm }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        default = self.packages.${system}.my-microvm;
        my-microvm = self.nixosConfigurations.my-microvm.config.microvm.declaredRunner;
      };

      apps.${system}.default = {
        type = "app";
        program =
          let
            runner = self.packages.${system}.my-microvm;
            script = pkgs.writeShellScript "run-microvm" ''
              SOCK="my-microvm-virtiofs-ro-store.sock"
              cleanup() {
                kill "$VIRTIOFSD_PID" 2>/dev/null
                wait "$VIRTIOFSD_PID" 2>/dev/null
                rm -f "$SOCK" "$SOCK.pid" control.socket
              }
              trap cleanup EXIT
              rm -f "$SOCK"
              ${pkgs.virtiofsd}/bin/virtiofsd \
                --socket-path="$SOCK" \
                --shared-dir=/nix/store \
                --sandbox=none \
                --cache=always \
                --readonly &
              VIRTIOFSD_PID=$!
              while [ ! -S "$SOCK" ]; do sleep 0.01; done
              ${runner}/bin/microvm-run
            '';
          in
          "${script}";
      };

      nixosConfigurations = {
        my-microvm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Microvm module for settings
            microvm.nixosModules.microvm
            # Official nixpkgs minimal config
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            # Our custom minimal config
            ./minimal.nix
            # Qemu-specific options
            ./qemu.nix
            # The actual system config
            (import ./microvm.nix { hostname = "my-microvm"; })
          ];
        };
      };
    };
}
