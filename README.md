## Steps to use this on a new system:

1. Install Command Line Tools

`xcode-select --install`

2. Install nix

`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install`

3. Run the build script

`nix --extra-experimental-features "nix-command flakes" run nix-darwin/nix-darwin-24.11#darwin-rebuild -- switch --flake ~/.config/nix`

For updates:

`nix flake update --flake ~/.config/nix`

`darwin-rebuild switch --flake ~/.config/nix`

Or `nfu && drs` if you use my `.zshrc`

Manual garbage collect:

`nix-store --gc`
