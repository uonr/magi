{ ... }: {
  # minecraft server
  networking.firewall.allowedTCPPorts = [ 25565 ];
  services.nginx.streamConfig = ''
    server {
      listen 25565;
      proxy_pass 154.31.112.93:25565;
    }
  '';
}
