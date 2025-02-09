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
            options = "--delete-older-than 14d";
            interval = [
              {
                Hour = 3;
                Minute = 0;
              }
            ];
          };
          nix.optimise.automatic = true;

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
            pkgs.tree
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
          # General UI/UX
          system.defaults = {
            NSGlobalDomain = {
              AppleICUForce24HourTime = true;
              AppleInterfaceStyleSwitchesAutomatically = true;
              AppleKeyboardUIMode = 3;
              AppleShowAllExtensions = true;
              NSAutomaticSpellingCorrectionEnabled = false;
              NSAutomaticWindowAnimationsEnabled = false;
              NSDocumentSaveNewDocumentsToCloud = false;
              NSNavPanelExpandedStateForSaveMode = true;
              NSNavPanelExpandedStateForSaveMode2 = true;
              NSTableViewDefaultSizeMode = 1;
              NSWindowResizeTime = 0.0;
              NSWindowShouldDragOnGesture = true;
              PMPrintingExpandedStateForPrint = true;
              PMPrintingExpandedStateForPrint2 = true;
              "com.apple.mouse.tapBehavior" = 1;
              "com.apple.springing.delay" = 0.0;
              "com.apple.springing.enabled" = true;
            };

            alf.globalstate = 1;
            alf.stealthenabled = 1;
            SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
            LaunchServices.LSQuarantine = false;

            WindowManager = {
              EnableStandardClickToShowDesktop = false;
              StageManagerHideWidgets = true;
              StandardHideWidgets = true;
            };

            # Login screen
            loginwindow = {
              DisableConsoleAccess = true;
              GuestEnabled = false;
              PowerOffDisabledWhileLoggedIn = true;
              RestartDisabledWhileLoggedIn = true;
              ShutDownDisabledWhileLoggedIn = true;
              SHOWFULLNAME = true;
            };

            screencapture.disable-shadow = true;
            screencapture.location = "~/Pictures/Screenshots";

            screensaver.askForPassword = true;
            screensaver.askForPasswordDelay = 0;

            # Finder
            finder = {
              # AppleShowAllExtensions = true;
              FXDefaultSearchScope = "SCcf";
              FXEnableExtensionChangeWarning = false;
              FXPreferredViewStyle = "Nlsv";
              FXRemoveOldTrashItems = true;
              NewWindowTarget = "Home";
              QuitMenuItem = true;
              ShowMountedServersOnDesktop = true;
              ShowPathbar = true;
              ShowStatusBar = true;
              _FXSortFoldersFirst = true;
              _FXSortFoldersFirstOnDesktop = true;
            };

            # Dock
            dock = {
              enable-spring-load-actions-on-all-items = true;
              appswitcher-all-displays = true;
              autohide = true;
              autohide-delay = 0.0;
              autohide-time-modifier = 0.0;
              expose-animation-duration = 0.1;
              launchanim = false;
              minimize-to-application = true;
              show-process-indicators = true;
              show-recents = false;
              showhidden = true;
              wvous-br-corner = 1;
              # persistent-apps = [
              #   "/Applications/Safari.app"
              # ];
              # persistent-others = [
              #   "~/Downloads"
              # ];
            };
          };

          # Custom settings not available in nix-darwin (yet)
          system.defaults.CustomSystemPreferences = {
            # Privacy
            "com.microsoft.office" = {
              "DiagnosticDataTypePreference" = "ZeroDiagnosticData";
            };
            "com.apple.AdLib" = {
              "allowIdentifierForAdvertising" = false;
              "allowApplePersonalizedAdvertising" = false;
              "forceLimitAdTracking" = true;
            };
            "NSGlobalDomain" = {
              "WebAutomaticSpellingCorrectionEnabled" = true;
            };
            "com.apple.systempreferences" = {
              "NSQuitAlwaysKeepsWindows" = false;
            };
            "com.apple.Siri" = {
              "StatusMenuVisible" = false;
              "UserHasDeclinedEnable" = false;
            };
            "com.apple.systemuiserver" = {
              "NSStatusItem Visible Siri" = 0;
            };
            "com.apple.SetupAssistant" = {
              "DidSeeSiriSetup" = true;
            };
            "com.apple.assistant.support" = {
              "Assistant Enabled" = false;
            };
            "com.apple.assistant.backedup" = {
              "Use device speaker for TTS" = 3;
            };
            "com.apple.desktopservices" = {
              "DSDontWriteNetworkStores" = true;
              "DSDontWriteUSBStores" = true;
            };
            "com.apple.finder" = {
              "DisableAllAnimations" = true;
              "WarnOnEmptyTrash" = false;
            };
            "com.apple.print.PrintingPrefs" = {
              "Quit When Finished" = true;
            };
            # Mail
            "com.apple.mail" = {
              "DisableInlineAttachmentViewing" = true;
              "AddressesIncludeNameOnPasteboard" = false;
              "DisableReplyAnimations" = true;
              "DisableSendAnimations" = true;
            };
            # Activity Monitor
            "com.apple.ActivityMonitor" = {
              "OpenMainWindow" = true;
              "IconType" = 5;
              "ShowCategory" = 0;
              "SortColumn" = "CPUUsage";
              "SortDirection" = 0;
            };
            # Mac App Store
            "com.apple.SoftwareUpdate" = {
              "AutomaticCheckEnabled" = true;
              "ScheduleFrequency" = 1;
            };
            # TextEdit
            "com.apple.TextEdit" = {
              "NSShowAppCentricOpenPanelInsteadOfUntitledFile" = false;
              "RichText" = 0;
              "PlainTextEncoding" = 4;
              "PlainTextEncodingForWrite" = 4;
            };
            # Disk Utility
            "com.apple.DiskUtility" = {
              "DUDebugMenuEnabled" = true;
              "advanced-image-options" = true;
            };
            "com.apple.ImageCapture" = {
              "disableHotPlug" = true;
            };
            "com.apple.TimeMachine" = {
              "DoNotOfferNewDisksForBackup" = true;
            };
          };

          system.startup.chime = false;

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
