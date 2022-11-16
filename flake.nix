{
  description = "Jade's Nix templates";

  outputs = { self }: {
    templates = {
      rust = {
        path = ./rust;
        description = "Rust project with naersk and rust-overlay";
        welcomeText = ''
          Hewwo! It's time for UwUst! :3
        '';
      };
    };
  };
}
