{ ... }:

let
  factorioOverlay = self: super: {
    factorio-headless = super.factorio-headless.overrideAttrs (old: rec {
      version = "1.1.46";
      name = "factorio-headless-${version}";
      src = super.fetchurl {
        url = "https://factorio.com/get-download/1.1.46/headless/linux64";
        name = "factorio_headless_x64-${version}.tar.xz";
        sha256 = "xJ/NBwQR6tdwoAz/1RZmcGwutqETWgzyAlpg5ls2ba0=";
      };
    });
  };
in
{
  nixpkgs.overlays = [ factorioOverlay ];
  services.factorio = {
    admins = ["miiiikan"];
    lan = true;
    openFirewall = true;
    game-name = "Peanut";
    saveName = "peanut";
    description = "uwu";
  };
}
