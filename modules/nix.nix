{ pkgs, ... }:
{
  nix = {
    # Ensure that flake support is enabled.
    package = pkgs.nixUnstable;
    gc = {
      automatic = true;
      dates = "Wed";
      options = "--delete-older-than 8d";
    };
    trustedUsers = [ "@wheel" ];
    allowedUsers = [ "@wheel" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
