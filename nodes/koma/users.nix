{ config, pkgs, ... }:

{

  system.activationScripts.mangaInit.text = 
  let
    avatar = ../../share/avatar.jpg;
    iconPath = "/var/lib/AccountsService/icons/mikan";
  in ''
    cp ${avatar} ${iconPath}
    chmod 644 ${iconPath}
  '';
  # https://nixos.wiki/wiki/Yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    # pinentryFlavor = "curses";
    enableSSHSupport = true;
    enableExtraSocket = true;
  };
  services.yubikey-agent.enable = false;
  security.pam.yubico = {                                                                                                                                                                                                                                                
    enable = true;                                                                                                      
    debug = true;                                                                                                       
    mode = "challenge-response";                                                                                        
  };
  # the PCSC-Lite daemon sometimes conflicts with gpg-agent.
  # services.pcscd.enable = true;
  # security.pam.services.gdm.enableGnomeKeyring = true;
  # services.gnome.gnome-keyring.enable = true;
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = config.sshKeys;
  users.users.mikan = {
    isNormalUser = true;
    uid = 1000;
    openssh.authorizedKeys.keys = config.sshKeys;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "disk" "systemd-journal" "docker" ]; # Enable ‘sudo’ for the user.
  };
  users.users.root.shell = pkgs.zsh;
  users.users.mikan.shell = pkgs.zsh;
  home-manager.users.root = { ... }: {
    imports = [ ../../modules/home.nix ];
  };
  home-manager.users.mikan = { config, pkgs, lib, ... }:

  {
    imports = [
      ../../modules/home.nix
    ];

    home.packages = with pkgs; [
      tdesktop
      google-chrome
      _1password-gui
      calibre
      minecraft
      vscode
      obsidian
      steam
      yubikey-manager
      cockatrice
      anki
      vlc
    ];
    programs.git = {
      userName = "Tachibana Kiyomi";
      userEmail = "me@yuru.me";
      signing.key = "FFF6DDE2181C1F55E8885470C02D23F17563AA95";
    };
  };
  security.sudo.extraRules = [
    {
      users = [ "mikan" ];
      commands = [
        {
          command = "ALL" ;
          options= [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];
}
