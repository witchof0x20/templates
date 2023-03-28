{
  description = "Jade's Nix templates";

  outputs = { self }: {
    templates = {
      packages = {
        path = ./packages;
        description = "For when I just need a couple dependencies for a project";
        welcomeText = ''
          Hewwo!
        '';
      };
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
