{...}: {
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.unbound = {
    enable = true;
    settings = {
      server = {
        access-control = [
          "10.0.0.0/8 allow"
          "127.0.0.0/8 allow"
          "192.168.0.0/16 allow"
        ];
        interface = [ "0.0.0.0" ];
        local-zone = [
          ''"lime.a" redirect''
          ''"negi.a" redirect''
          ''"yuudachi.a" redirect''
          ''"alice.a" redirect''
          ''"fubuki.a" redirect''
          ''"mithal.a" redirect''
          ''"koma.a" redirect''
        ];
        local-data = [
          ''"lime.a A 10.110.1.1"''
          ''"yuudachi.a A 10.110.1.2"''
          ''"alice.a A 10.110.102.1"''
          ''"negi.a A 10.110.100.10"''
          ''"fubuki.a A 10.110.101.1"''
          ''"mithal.a A 10.110.100.1"''
          ''"koma.a A 10.110.100.2"''
        ];
      };
      forward-zone = {
        name = ".";
        forward-addr = [
          "1.1.1.1@53#one.one.one.one"
          "8.8.8.8@53#dns.google"
          "1.0.0.1@53#one.one.one.one"
          "8.8.4.4@53#dns.google"
        ];
      };
      #local-zone = [
      #  ''koma.wired. transparent''
      #];
      #local-data = [
      #  ''"koma.wired. A 10.110.100.2"''
      #];
    };
  };
}
