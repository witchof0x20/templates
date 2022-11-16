{
  description = "Jade's Nix templates";

  templates = {
    rust = {
      path = ./rust;
      description = "Rust project with naersk and rust-overlay";
      welcomeText = ''
        Hewwo! It's time for UwUst! :3
      '';
    };
  };
}
