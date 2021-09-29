{ config, pkgs, ... }:
let 
  sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1yfkf508knd4xRqcRBHXYENMGV2E3bnE8fiRxPKUoyjcv5OLdFMpdNMnXUJtkzZljpJ9DsdfcQeCRl1wPkJeHH9Q1envjh9tqhxXWMlPzHKZHJyPbsKaerSTldcezZluqQIgOszlTvoOgRa4PGGd9oeZ6BdQvUxNlWBrSIwAoUDeuflSWg4WGYeF9bTl6dh7yOhXcfsVETtzj5DLsojcsh3n0NBfSofE9Y0WVdS6MDgEyFGancBJrbyME0aFwFDni839pVGMACOQW5epLdDbAA0nGuukhfx88+RY5AaIB8BF+paMLJShwNJoSGCFu8GuMe82K5m1HByKP0CO1TLdDxxps2O+r97QeBtBXZRIF2C4iNCoFhgMWD2juh+y9vFJ+rYCwzHJpOnmdt738TMOCBRAtN0IXBOHpDvAMBUPd/UlgcTzhexI2VeQmCq08o1AtYPXFmxLhpNkcGAdjLBOXDqB1kriBnLbj1+cxf/ufXvjL8CySzBIT+HVCp3eg/X9T1b+cHmFHgoRkaMkXIPlXsVtGrvR2ZrsLmwixns2WQWgKZq53o+H9ssuko5S9jOgZbKoWRnRxaSEnB1yxCoJUOVigvpPAg7RdNwVV6MhT24CXpZFsIyTBgSO6Wg1G/Mf95WBRo4BAH5DXiTNdGiEpJrjzi0VSR68ATVIQoMBqnQ==";
  hostName = "nixos";
  # Generate by `mkpasswd -m sha-512`
  initialHashedPassword = "";
  # ip address show
  ipv4 = "";
  ipv6 = "";
  # ip route show
  defaultGateway = "";
  # ip -6 route show
  defaultGateway6 = "";
  # cat /etc/resolv.conf
  nameservers = [ "8.8.8.8" "8.8.4.4" ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Set your time zone.
  time.timeZone = "UTC";

  networking = {
    hostName = hostName;
    enableIPv6 = true;
    usePredictableInterfaceNames = false;
    
    inherit nameservers;
    defaultGateway = defaultGateway;
    defaultGateway6 = defaultGateway6;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address = ipv4; prefixLength = 32; }
        ];
        ipv4.routes = [ { address = defaultGateway; prefixLength = 32; } ];
        ipv6.addresses = [
          { address = ipv6; prefixLength = 64; }
        ];
        ipv6.routes = [ { address = defaultGateway6; prefixLength = 64; } ];
      };
    };
  };

  users.users.root.initialHashedPassword = initialHashedPassword;
  users.users.root.openssh.authorizedKeys.keys = [ sshKey ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim 
    wget
    git
    htop
    tmux
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "21.11";
}
