{ ... }: {

  services.netdata = {
    enable = true;
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."lime.netdata.yuru.me" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:19999";
    };
  };
}
