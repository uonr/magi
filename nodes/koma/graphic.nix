{ pkgs, ... }:

{
  imports = [
  ];

  nixpkgs.config.allowUnfree = true;
  
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome.enable = true;

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ rime libpinyin mozc ];
  };  

  environment.systemPackages = with pkgs; [
    gnomeExtensions.kimpanel
  ];
  environment.gnome.excludePackages = with pkgs; [
    gnome.cheese
    gnome.gnome-music
    gnome-tour
    gnome-connections
  ];

  fonts = {
    fonts = with pkgs; [
      sarasa-gothic
      source-han-sans
      source-han-serif
      iosevka
      victor-mono
      emojione
      ibm-plex
      cascadia-code
      fira-code
      recursive
      liberation_ttf
      ubuntu_font_family
      roboto
      lato
    ];
    fontDir.enable = true;
    fontconfig.defaultFonts = {
      monospace = [ "Sarasa Mono SC" ];
      sansSerif = [ "Sarasa UI SC" ];
      serif = [ "Sarasa UI SC" ];
      emoji = [ "EmojiOne Color" ];
    };
  };
}
