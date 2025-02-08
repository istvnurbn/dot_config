{
  description = "nix-darwin system flake for Samael";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      mac-app-util,
      nix-homebrew,
      # home-manager,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # Allow non-free packages
          nixpkgs.config.allowUnfree = true;

          # Automatic cleanup
          nix.gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 14d";
          };
          nix.settings.auto-optimise-store = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            # Command line utilities
            pkgs.nano
            pkgs.nixd
            pkgs.nixfmt-rfc-style
            pkgs.openssh
            pkgs.git
            pkgs.mc
            pkgs.wget
            pkgs.rsync
            pkgs.hugo
            pkgs.lame
            pkgs.flac
            pkgs.libcdio-paranoia
            pkgs.exiftool
            pkgs.pv
            pkgs.gawk
            pkgs.btop
            pkgs.meslo-lgs-nf
            pkgs.fzf
            pkgs.zoxide
            # Graphical stuff
            pkgs.zed-editor
            pkgs.localsend
            pkgs.brave
            pkgs.iina
            # pkgs.tailscale
            # pkgs.handbrake
            # pkgs.picard
            # pkgs.calibre
            # pkgs.protonmail-desktop
          ];

          homebrew = {
            enable = true;
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;

            brews = [
              "imessage-exporter"
            ];

            caskArgs.no_quarantine = true;

            casks = [
              "android-platform-tools"
              "calibre"
              "firefox"
              "font-zed-mono-nerd-font"
              "foobar2000"
              "ghostty"
              "git-credential-manager"
              "imageoptim"
              "jordanbaird-ice"
              "pearcleaner"
              "raindropio"
              "tailscale"
              "tor-browser"
              "utm"
              "librewolf"
              "messenger"
            ];

            masApps = {
              "Amphetamine" = 937984704;
              "BitWarden" = 1352778147;
              "Magnet" = 441258766;
            };
          };

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Necessary for nixd
          nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

          # Enable alternative shell support in nix-darwin.
          programs.zsh.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # System settings
          system.defaults = {
            NSGlobalDomain.AppleICUForce24HourTime = true;
            NSGlobalDomain.AppleShowAllExtensions = true;
            loginwindow.GuestEnabled = false;
          };

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Samael
      darwinConfigurations."Samael" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "istvnurbn";

              # Automatically migrate existing Homebrew installations
              autoMigrate = true;
            };
          }
          # home-manager.darwinModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.istvnurbn = import ./home.nix;
          #   users.users.istvnurbn.home = "/Users/istvnurbn";
          # }
        ];
      };
    };
}
